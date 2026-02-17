import type { NetworkState, WifiStatus } from "./types";

type IconLabel = string;

const no: IconLabel = "";

const wired: Record<"no" | "lan" | "wan", IconLabel> = {
  no: "",
  lan: "",
  wan: "󰈀",
};

const wifi: Record<Exclude<WifiStatus, "no">, IconLabel> = {
  "wan-4": "󰣺",
  "wan-3": "󰣸",
  "wan-2": "󰣶",
  "wan-1": "󰣴",
  "lan-4": "󰣻",
  "lan-3": "󰣹",
  "lan-2": "󰣷",
  "lan-1": "󰣵",
};

export function getNetworkIconLabel(state: NetworkState): IconLabel {
  if (state.status === "wired") {
    return wired[state.wired.status];
  }

  if (state.status === "wifi") {
    return state.wifi.status === "no" ? no : wifi[state.wifi.status];
  }

  return no;
}

export function getNetworkIcon(state: NetworkState): JSX.Element {
  return <label label={getNetworkIconLabel(state)} />;
}
