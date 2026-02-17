import AstalBluetooth from "gi://AstalBluetooth?version=0.1";
import { execAsync } from "ags/process";
import { createPoll } from "ags/time";
import { LabeledWidgetButton } from "../../components/outer";
import BluetoothPopover from "./popover";

type DeviceKind = "audio" | "mouse" | "other";

const ICONS = {
  off: "󰂲",
  idle: "󰂯",
  audio: "󰗾",
  mouse: "󰦋",
  other: "󰂱",
} as const;

const bluetooth = AstalBluetooth.Bluetooth.get_default();
const UPOWER_TTL_MS = 10000;

let upowerCache: Record<string, number> = {};
let upowerUpdatedAt = 0;
let upowerRefreshInFlight: Promise<void> | null = null;

function normalizeAddress(value?: string | null): string | null {
  if (!value) return null;
  const match = value.match(/([0-9A-Fa-f]{2}([:_-])[0-9A-Fa-f]{2}(?:\2[0-9A-Fa-f]{2}){4})/);
  if (!match) return null;
  return match[1].replace(/[_-]/g, ":").toUpperCase();
}

function parseUpower(output: string): Record<string, number> {
  const map: Record<string, number> = {};
  const lines = output.split("\n");
  let block: string[] = [];

  const flush = () => {
    if (block.length === 0) return;

    let nativePath = "";
    let serial = "";
    let percentage: number | null = null;

    for (const line of block) {
      const nativeMatch = line.match(/^\s*native-path:\s*(.+)\s*$/);
      if (nativeMatch) nativePath = nativeMatch[1];

      const serialMatch = line.match(/^\s*serial:\s*(.+)\s*$/);
      if (serialMatch) serial = serialMatch[1];

      const percentMatch = line.match(/^\s*percentage:\s*([0-9.]+)%\s*$/);
      if (percentMatch) percentage = Math.round(Number(percentMatch[1]));
    }

    if (percentage === null) {
      block = [];
      return;
    }

    const address = normalizeAddress(nativePath) ?? normalizeAddress(serial);
    if (address) map[address] = percentage;
    block = [];
  };

  for (const line of lines) {
    if (line.startsWith("Device:")) {
      flush();
      block = [line];
    } else {
      block.push(line);
    }
  }
  flush();

  return map;
}

async function refreshUpowerCache(): Promise<void> {
  if (Date.now() - upowerUpdatedAt < UPOWER_TTL_MS) return;
  if (upowerRefreshInFlight) {
    return upowerRefreshInFlight;
  }

  upowerRefreshInFlight = (async () => {
    try {
      const output = await execAsync(["upower", "-d"]);
      upowerCache = parseUpower(output);
      upowerUpdatedAt = Date.now();
    } catch (error) {
      // If upower isn't available, just skip.
      upowerCache = {};
    } finally {
      upowerRefreshInFlight = null;
    }
  })();

  await upowerRefreshInFlight;
}

function deviceKind(device: AstalBluetooth.Device): DeviceKind {
  const icon = (device.icon ?? "").toLowerCase();
  if (icon.includes("audio") || icon.includes("headset") || icon.includes("headphone") || icon.includes("speaker")) {
    return "audio";
  }
  if (icon.includes("mouse")) {
    return "mouse";
  }
  return "other";
}

function getBatteryPercent(device: AstalBluetooth.Device): number {
  const rawBattery =
    typeof device.batteryPercentage === "number"
      ? device.batteryPercentage
      : typeof (device as { battery_percentage?: number }).battery_percentage === "number"
        ? (device as { battery_percentage?: number }).battery_percentage!
        : typeof device.get_battery_percentage === "function"
          ? device.get_battery_percentage()
          : -1;

  if (typeof rawBattery !== "number" || rawBattery < 0) return -1;
  return Math.round(rawBattery <= 1 ? rawBattery * 100 : rawBattery);
}

function devicePriority(kind: DeviceKind): number {
  if (kind === "audio") return 0;
  if (kind === "mouse") return 1;
  return 2;
}

function pickDevice(devices: AstalBluetooth.Device[]): AstalBluetooth.Device | null {
  const connected = devices.filter((device) => device.connected);
  if (connected.length === 0) return null;

  const sorted = [...connected].sort((a, b) => {
    const priorityDiff = devicePriority(deviceKind(a)) - devicePriority(deviceKind(b));
    if (priorityDiff !== 0) return priorityDiff;

    const batteryDiff = getBatteryPercent(b) - getBatteryPercent(a);
    if (batteryDiff !== 0) return batteryDiff;

    const aName = (a.alias || a.name || "").toLowerCase();
    const bName = (b.alias || b.name || "").toLowerCase();
    return aName.localeCompare(bName);
  });

  return sorted[0] ?? null;
}

async function buildLabel(): Promise<string> {
  if (!bluetooth || !bluetooth.isPowered) return ICONS.off;

  const devices = bluetooth.devices ?? [];
  const device = pickDevice(devices);
  if (!device) return ICONS.idle;

  const kind = deviceKind(device);
  const icon = ICONS[kind] ?? ICONS.other;
  const name = device.alias || device.name || "Bluetooth";
  let battery = getBatteryPercent(device);

  if (battery < 0) {
    await refreshUpowerCache();
    const address = normalizeAddress(device.address);
    if (address && typeof upowerCache[address] === "number") {
      battery = upowerCache[address];
    }
  }

  const batteryText = battery >= 0 ? ` (${battery}%)` : "";
  return `${icon} ${name}${batteryText}`;
}

export default function Bluetooth() {
  const label = createPoll("", 2000, () => buildLabel());

  return (
    <LabeledWidgetButton
      className="bluetooth"
      child={<label label={label} />}
      menu={(menu) => <BluetoothPopover open={menu.open} flip={menu.flip} />}
    />
  );
}
