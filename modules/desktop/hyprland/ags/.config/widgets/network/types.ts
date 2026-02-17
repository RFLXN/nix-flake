import type AstalNetwork from "gi://AstalNetwork?version=0.1";

export type WifiLevel = 1 | 2 | 3 | 4;

export type WiredStatus = "no" | "lan" | "wan";
export type WifiStatus = "no" | `lan-${WifiLevel}` | `wan-${WifiLevel}`;

export type WiredInfo = {
  interface: string | null;
  ip4: string[];
  ip6: string[];
  mac: string | null;
};

export type AccessPointInfo = {
  id: string;
  name: string;
  strength: number;
  requirePassword: boolean;
  ap?: AstalNetwork.AccessPoint;
};

export type WifiInfo = WiredInfo & {
  currentAp: AccessPointInfo | null;
  aps: AccessPointInfo[];
};

export type InterfaceDetails = {
  name: string;
  kind: "wired" | "wireless" | "other";
  status: "no" | "lan" | "wan";
  ip4: string[];
  ip6: string[];
  mac: string | null;
};

export type NetworkState = {
  status: "no" | "wired" | "wifi";
  wired: {
    status: WiredStatus;
    info: WiredInfo;
  };
  wifi: {
    status: WifiStatus;
    info: WifiInfo;
  };
  others: InterfaceDetails[];
};
