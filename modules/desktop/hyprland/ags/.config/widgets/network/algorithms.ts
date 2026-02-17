import type { AccessPointInfo, WifiLevel } from "./types";

export type WifiListItem = AccessPointInfo & { connected: boolean };

function normalizeToken(value: string): string {
  return value.trim().toLowerCase();
}

export function strengthToLevel(strength: number): WifiLevel {
  if (strength >= 75) return 4;
  if (strength >= 50) return 3;
  if (strength >= 25) return 2;
  return 1;
}

export function getWifiSignalIcon(strength: number): string {
  const level = strengthToLevel(strength);
  if (level === 4) return "󰣺";
  if (level === 3) return "󰣸";
  if (level === 2) return "󰣶";
  return "󰣴";
}

export function getAccessPointKey(ap: Pick<AccessPointInfo, "id" | "name">): string {
  const name = normalizeToken(ap.name ?? "");
  if (name) return `name:${name}`;

  const id = normalizeToken(ap.id ?? "");
  if (id) return `id:${id}`;

  return "";
}

export function isSameAccessPoint(
  a: Pick<AccessPointInfo, "id" | "name"> | null,
  b: Pick<AccessPointInfo, "id" | "name"> | null,
): boolean {
  if (!a || !b) return false;

  const aKey = getAccessPointKey(a);
  const bKey = getAccessPointKey(b);
  if (aKey && bKey) return aKey === bKey;

  const aName = normalizeToken(a.name ?? "");
  const bName = normalizeToken(b.name ?? "");
  return Boolean(aName && bName && aName === bName);
}

function pickBetterEntry(a: WifiListItem, b: WifiListItem): WifiListItem {
  if (a.connected !== b.connected) return a.connected ? a : b;
  if (a.strength !== b.strength) return a.strength > b.strength ? a : b;
  if (a.requirePassword !== b.requirePassword) return a.requirePassword ? a : b;
  return normalizeToken(a.name).localeCompare(normalizeToken(b.name)) <= 0 ? a : b;
}

export function buildWifiList(
  currentAp: AccessPointInfo | null,
  accessPoints: AccessPointInfo[],
): WifiListItem[] {
  const merged = new Map<string, WifiListItem>();
  const source = currentAp ? [currentAp, ...accessPoints] : [...accessPoints];

  for (const ap of source) {
    const connected = isSameAccessPoint(currentAp, ap);
    const item: WifiListItem = { ...ap, connected };
    const key = getAccessPointKey(item) || `anon:${normalizeToken(item.name)}:${item.strength}`;
    const existing = merged.get(key);
    merged.set(key, existing ? pickBetterEntry(existing, item) : item);
  }

  return Array.from(merged.values())
    .filter((ap) => Boolean(ap.name || ap.id))
    .sort((a, b) => {
      if (a.connected !== b.connected) return a.connected ? -1 : 1;
      if (a.strength !== b.strength) return b.strength - a.strength;
      const byName = normalizeToken(a.name).localeCompare(normalizeToken(b.name));
      if (byName !== 0) return byName;
      return normalizeToken(a.id).localeCompare(normalizeToken(b.id));
    });
}
