import AstalNetwork from "gi://AstalNetwork?version=0.1";
import { createPoll } from "ags/time";
import { execAsync } from "ags/process";
import { strengthToLevel } from "./algorithms";

import type {
  AccessPointInfo,
  InterfaceDetails,
  NetworkState,
  WifiInfo,
  WifiStatus,
  WiredInfo,
  WiredStatus,
} from "./types";

const network = AstalNetwork.Network.get_default();

const emptyWiredInfo: WiredInfo = { interface: null, ip4: [], ip6: [], mac: null };
const emptyWifiInfo: WifiInfo = {
  interface: null,
  ip4: [],
  ip6: [],
  mac: null,
  currentAp: null,
  aps: [],
};

const emptyState: NetworkState = {
  status: "no",
  wired: { status: "no", info: emptyWiredInfo },
  wifi: { status: "no", info: emptyWifiInfo },
  others: [],
};

type JsonRecord = Record<string, unknown>;
type InterfaceSnapshot = { ip4: string[]; ip6: string[]; mac: string | null };
type ListModelLike<T> = {
  get_n_items: () => number;
  get_item: (index: number) => T | null;
};
type DeviceLike = {
  get_iface?: () => string | null;
  getIface?: () => string | null;
  iface?: string | null;
};

const SNAPSHOT_TTL_MS = 2500;

let snapshotCache: Record<string, InterfaceSnapshot> = {};
let snapshotUpdatedAt = 0;
let snapshotInFlight: Promise<Record<string, InterfaceSnapshot>> | null = null;

function isRecord(value: unknown): value is JsonRecord {
  return typeof value === "object" && value !== null;
}

function isNonEmptyString(value: unknown): value is string {
  return typeof value === "string" && value.length > 0;
}

function readInterfaceName(entry: JsonRecord): string | null {
  const name = entry.ifname ?? entry.ifName ?? entry.name;
  return isNonEmptyString(name) ? name : null;
}

function toRecordArray(value: unknown): JsonRecord[] {
  if (!Array.isArray(value)) return [];
  return value.filter(isRecord);
}

function isListModelLike<T>(value: unknown): value is ListModelLike<T> {
  if (!isRecord(value)) return false;
  return typeof value.get_n_items === "function" && typeof value.get_item === "function";
}

function listToArray<T>(list: unknown): T[] {
  if (!list) return [];
  if (Array.isArray(list)) return list as T[];
  if (!isListModelLike<T>(list)) return [];

  const items: T[] = [];
  const total = list.get_n_items();
  for (let index = 0; index < total; index += 1) {
    const item = list.get_item(index);
    if (item !== null && item !== undefined) {
      items.push(item);
    }
  }
  return items;
}

function uniqueSorted(values: string[]): string[] {
  return Array.from(new Set(values.filter(isNonEmptyString))).sort();
}

function mergeSnapshot(
  prev: InterfaceSnapshot | undefined,
  next: Partial<InterfaceSnapshot>,
): InterfaceSnapshot {
  return {
    ip4: uniqueSorted([...(prev?.ip4 ?? []), ...(next.ip4 ?? [])]),
    ip6: uniqueSorted([...(prev?.ip6 ?? []), ...(next.ip6 ?? [])]),
    mac: next.mac ?? prev?.mac ?? null,
  };
}

function normalizeAccessPoint(ap: AstalNetwork.AccessPoint): AccessPointInfo {
  const name = ap.ssid ?? "";
  const id = isNonEmptyString(ap.bssid) ? ap.bssid : name;

  return {
    id,
    name,
    strength: typeof ap.strength === "number" ? ap.strength : 0,
    requirePassword: Boolean(ap.requiresPassword ?? ap.requires_password),
    ap,
  };
}

async function queryInterfaceSnapshot(): Promise<Record<string, InterfaceSnapshot>> {
  const result: Record<string, InterfaceSnapshot> = {};

  try {
    const raw = await execAsync(["ip", "-j", "addr"]);
    const parsed: unknown = JSON.parse(raw);

    for (const entry of toRecordArray(parsed)) {
      const name = readInterfaceName(entry);
      if (!name) continue;

      const addresses = toRecordArray(entry.addr_info);
      const ip4 = addresses
        .filter((address) => address.family === "inet")
        .map((address) => address.local)
        .filter(isNonEmptyString);
      const ip6 = addresses
        .filter((address) => address.family === "inet6")
        .map((address) => address.local)
        .filter(isNonEmptyString);

      result[name] = mergeSnapshot(result[name], { ip4, ip6 });
    }
  } catch (error) {
    console.error("network: failed to read IPs", error);
  }

  try {
    const raw = await execAsync(["ip", "-j", "link"]);
    const parsed: unknown = JSON.parse(raw);

    for (const entry of toRecordArray(parsed)) {
      const name = readInterfaceName(entry);
      if (!name) continue;

      const mac = isNonEmptyString(entry.address) ? entry.address : null;
      result[name] = mergeSnapshot(result[name], { mac });
    }
  } catch (error) {
    console.error("network: failed to read MACs", error);
  }

  return result;
}

async function getInterfaceSnapshot(): Promise<Record<string, InterfaceSnapshot>> {
  const now = Date.now();
  if (now - snapshotUpdatedAt < SNAPSHOT_TTL_MS && Object.keys(snapshotCache).length > 0) {
    return snapshotCache;
  }

  if (snapshotInFlight) {
    return snapshotInFlight;
  }

  snapshotInFlight = queryInterfaceSnapshot()
    .then((next) => {
      snapshotCache = next;
      snapshotUpdatedAt = Date.now();
      return next;
    })
    .finally(() => {
      snapshotInFlight = null;
    });

  return snapshotInFlight;
}

function getWiredStatus(wired: AstalNetwork.Wired | null | undefined): WiredStatus {
  if (!wired) return "no";

  const state = wired.state ?? AstalNetwork.DeviceState.UNKNOWN;
  if (state <= AstalNetwork.DeviceState.DISCONNECTED) return "no";

  const internet = wired.internet ?? AstalNetwork.Internet.DISCONNECTED;
  return internet === AstalNetwork.Internet.CONNECTED ? "wan" : "lan";
}

function getWifiStatus(wifi: AstalNetwork.Wifi | null | undefined): WifiStatus {
  if (!wifi || !wifi.enabled) return "no";

  const state = wifi.state ?? AstalNetwork.DeviceState.UNKNOWN;
  if (state <= AstalNetwork.DeviceState.DISCONNECTED) return "no";

  const strength = typeof wifi.strength === "number" ? wifi.strength : 0;
  const level = strengthToLevel(strength);
  const internet = wifi.internet ?? AstalNetwork.Internet.DISCONNECTED;
  const prefix = internet === AstalNetwork.Internet.CONNECTED ? "wan" : "lan";
  return `${prefix}-${level}` as WifiStatus;
}

function getInterfaceName(device: DeviceLike | null | undefined): string | null {
  if (!device) return null;

  const iface =
    (typeof device.get_iface === "function" ? device.get_iface() : null) ??
    (typeof device.getIface === "function" ? device.getIface() : null) ??
    device.iface;

  return isNonEmptyString(iface) ? iface : null;
}

function getWifiInfo(wifi: AstalNetwork.Wifi | null | undefined): WifiInfo {
  if (!wifi) return { ...emptyWifiInfo };

  const iface = getInterfaceName(wifi.device);
  const wifiState = wifi.state ?? AstalNetwork.DeviceState.UNKNOWN;
  const isActive = wifiState > AstalNetwork.DeviceState.DISCONNECTED;
  const current = wifi.activeAccessPoint
    ? normalizeAccessPoint(wifi.activeAccessPoint)
    : isActive && isNonEmptyString(wifi.ssid)
      ? {
          id: wifi.ssid,
          name: wifi.ssid,
          strength: typeof wifi.strength === "number" ? wifi.strength : 0,
          requirePassword: false,
        }
      : null;

  const aps = listToArray<AstalNetwork.AccessPoint>(wifi.accessPoints).map(normalizeAccessPoint);

  return {
    interface: iface,
    ip4: [],
    ip6: [],
    mac: null,
    currentAp: current,
    aps,
  };
}

function getWiredInfo(wired: AstalNetwork.Wired | null | undefined): WiredInfo {
  if (!wired) return { ...emptyWiredInfo };

  return {
    interface: getInterfaceName(wired.device),
    ip4: [],
    ip6: [],
    mac: null,
  };
}

async function fetchNetworkState(): Promise<NetworkState> {
  if (!network) return { ...emptyState };

  const wired = network.wired;
  const wifi = network.wifi;

  const wiredInfo = getWiredInfo(wired);
  const wifiInfo = getWifiInfo(wifi);

  const snapshots = await getInterfaceSnapshot();
  if (wiredInfo.interface) {
    const snapshot = snapshots[wiredInfo.interface];
    if (snapshot) {
      wiredInfo.ip4 = snapshot.ip4;
      wiredInfo.ip6 = snapshot.ip6;
      wiredInfo.mac = snapshot.mac;
    }
  }

  if (wifiInfo.interface) {
    const snapshot = snapshots[wifiInfo.interface];
    if (snapshot) {
      wifiInfo.ip4 = snapshot.ip4;
      wifiInfo.ip6 = snapshot.ip6;
      wifiInfo.mac = snapshot.mac;
    }
  }

  const wiredStatus = getWiredStatus(wired);
  const wifiStatus = getWifiStatus(wifi);

  let status: NetworkState["status"] = "no";
  if (network.primary === AstalNetwork.Primary.WIRED) status = "wired";
  else if (network.primary === AstalNetwork.Primary.WIFI) status = "wifi";
  else if (wifiStatus !== "no") status = "wifi";
  else if (wiredStatus !== "no") status = "wired";

  const hardware = new Set<string>();
  if (wiredInfo.interface) hardware.add(wiredInfo.interface);
  if (wifiInfo.interface) hardware.add(wifiInfo.interface);

  const others: InterfaceDetails[] = Object.entries(snapshots)
    .filter(([name]) => name !== "lo" && !hardware.has(name))
    .map(([name, snapshot]) => ({
      name,
      kind: "other" as const,
      status: "no" as const,
      ip4: snapshot.ip4,
      ip6: snapshot.ip6,
      mac: snapshot.mac,
    }))
    .sort((a, b) => a.name.localeCompare(b.name));

  return {
    status,
    wired: { status: wiredStatus, info: wiredInfo },
    wifi: { status: wifiStatus, info: wifiInfo },
    others,
  };
}

export const networkState = createPoll<NetworkState>(emptyState, 3000, fetchNetworkState);
