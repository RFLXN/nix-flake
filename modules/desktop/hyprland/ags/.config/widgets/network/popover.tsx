import { Gtk } from "ags/gtk4";
import AstalNetwork from "gi://AstalNetwork?version=0.1";
import GLib from "gi://GLib";
import Pango from "gi://Pango";
import { For, createComputed, createState } from "gnim";
import type { Accessor } from "gnim";
import { Card } from "../../components/card";
import { CollapsableList, CollapsableListItem } from "../../components/collapsable-list";
import { PopoverScrollArea, PopoverTitleBlock, WidgetPopover } from "../../components/popover";
import {
  buildWifiList,
  getAccessPointKey,
  getWifiSignalIcon,
  isSameAccessPoint,
} from "./algorithms";
import type { WifiListItem } from "./algorithms";
import type { NetworkState, WifiStatus, WiredStatus } from "./types";

type NetworkPopoverProps = {
  state: Accessor<NetworkState>;
  open: Accessor<boolean>;
  flip: Accessor<boolean>;
};

type ConnectionStatus = "no" | "lan" | "wan";

const connectionStatusLabel: Record<ConnectionStatus, string> = {
  no: "no connection",
  lan: "LAN",
  wan: "WAN",
};

const WIFI_LOCK = "󰌾";
const DEBUG_WIFI = false;
const network = AstalNetwork.Network.get_default();

function normalizeWifiStatus(status: WifiStatus): ConnectionStatus {
  if (status === "no") return "no";
  return status.startsWith("wan") ? "wan" : "lan";
}

function normalizeWiredStatus(status: WiredStatus): ConnectionStatus {
  return status;
}

function joinList(values: string[]): string {
  return values.length ? values.join(", ") : "--";
}

export default function NetworkPopover({ state, open, flip }: NetworkPopoverProps) {
  const [errorState, setErrorState] = createState<{ label: string; target?: string } | null>(
    null,
  );
  const [panelOpenId, setPanelOpenId] = createState<string | null>(null);
  const [passwords, setPasswords] = createState<Record<string, string>>({});
  const [frozenList, setFrozenList] = createState<WifiListItem[] | null>(null);
  const [pendingAccessPoints, setPendingAccessPoints] = createState<Set<string>>(new Set());
  let errorTimeoutId: number | null = null;

  const hardware = state.as((networkState) => {
    const entries: Array<{
      name: string;
      kind: "wired" | "wireless";
      status: ConnectionStatus;
      ip4: string[];
      ip6: string[];
      mac: string | null;
    }> = [];

    if (networkState.wired.info.interface) {
      entries.push({
        name: networkState.wired.info.interface,
        kind: "wired",
        status: normalizeWiredStatus(networkState.wired.status),
        ip4: networkState.wired.info.ip4,
        ip6: networkState.wired.info.ip6,
        mac: networkState.wired.info.mac,
      });
    }

    if (networkState.wifi.info.interface) {
      entries.push({
        name: networkState.wifi.info.interface,
        kind: "wireless",
        status: normalizeWifiStatus(networkState.wifi.status),
        ip4: networkState.wifi.info.ip4,
        ip6: networkState.wifi.info.ip6,
        mac: networkState.wifi.info.mac,
      });
    }

    return entries;
  });

  const wifiList = state.as((networkState) => {
    const info = networkState.wifi.info;
    const list = buildWifiList(info.currentAp, info.aps);

    if (DEBUG_WIFI) {
      const extras = Array.from({ length: 12 }, (_, index) => ({
        id: `demo-${index + 1}`,
        name: `Demo-${index + 1}`,
        strength: Math.max(10, 90 - index * 6),
        requirePassword: index % 3 === 0,
        connected: false,
      }));
      return [...list, ...extras];
    }

    return list;
  });

  createComputed(() => {
    if (open()) {
      if (!frozenList()) setFrozenList(wifiList());
      return;
    }

    if (panelOpenId()) setPanelOpenId(null);
    if (frozenList()) setFrozenList(null);
  });

  const wifiListView = createComputed(() => frozenList() ?? wifiList());
  const showWifi = wifiList.as((list) => list.length > 0);

  const setError = (value: string, target?: string, ttlMs = 3000) => {
    if (errorTimeoutId !== null) {
      GLib.Source.remove(errorTimeoutId);
      errorTimeoutId = null;
    }

    setErrorState({ label: value, target });
    errorTimeoutId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, ttlMs, () => {
      setErrorState((prev) =>
        prev && prev.label === value && prev.target === target ? null : prev,
      );
      errorTimeoutId = null;
      return GLib.SOURCE_REMOVE;
    });
  };

  const runAccessPointOperation = async (entry: WifiListItem, run: () => Promise<void>) => {
    const entryKey = getAccessPointKey(entry) || entry.name || entry.id;
    if (pendingAccessPoints().has(entryKey)) return;

    setPendingAccessPoints((prev) => {
      const next = new Set(prev);
      next.add(entryKey);
      return next;
    });

    try {
      await run();
    } finally {
      setPendingAccessPoints((prev) => {
        if (!prev.has(entryKey)) return prev;
        const next = new Set(prev);
        next.delete(entryKey);
        return next;
      });
    }
  };

  const connectToAp = async (entry: WifiListItem, password?: string | null) => {
    const ap = entry.ap;
    if (!ap) return;

    const entryKey = getAccessPointKey(entry) || entry.name || entry.id;
    await runAccessPointOperation(entry, async () => {
      try {
        const normalizedPassword = typeof password === "string" ? password : null;
        await ap.activate(normalizedPassword);
      } catch (error) {
        console.error("network: failed to connect wifi", error);
        setError("- failed", entryKey);
      }
    });
  };

  const disconnectWifi = async (entry: WifiListItem) => {
    const wifi = network?.wifi;
    if (!wifi) return;

    const entryKey = getAccessPointKey(entry) || entry.name || entry.id;
    await runAccessPointOperation(entry, async () => {
      try {
        await wifi.deactivate_connection();
      } catch (error) {
        console.error("network: failed to disconnect wifi", error);
        setError("- failed", entryKey);
      }
    });
  };

  return (
    <WidgetPopover
      popoverClass="network-popover"
      menuClassName="network-menu"
      open={open}
      flip={flip}
    >
      <PopoverTitleBlock
        containerClass="network-header"
        titleClass="network-header-title"
        title="Networks"
      />
      <box class="network-hardware" orientation={Gtk.Orientation.VERTICAL} spacing={0}>
        <For each={hardware}>
          {(entry) => (
            <Card
              className="network-interface"
              spacing={4}
              header={
                <box class="network-interface-header" spacing={6}>
                  <label
                    class="network-interface-title"
                    label={`${entry.name} - ${entry.kind}, ${connectionStatusLabel[entry.status]}`}
                    hexpand
                    xalign={0}
                    ellipsize={Pango.EllipsizeMode.END}
                    lines={1}
                  />
                </box>
              }
              main={
                <box orientation={Gtk.Orientation.VERTICAL} spacing={0}>
                  <label
                    class="network-interface-meta"
                    label={`IPv4: ${joinList(entry.ip4)}`}
                    xalign={0}
                    ellipsize={Pango.EllipsizeMode.END}
                    lines={1}
                  />
                  <label
                    class="network-interface-meta"
                    label={`IPv6: ${joinList(entry.ip6)}`}
                    xalign={0}
                    ellipsize={Pango.EllipsizeMode.END}
                    lines={1}
                  />
                  <label
                    class="network-interface-meta"
                    label={`MAC: ${entry.mac ?? "--"}`}
                    xalign={0}
                    ellipsize={Pango.EllipsizeMode.END}
                    lines={1}
                  />
                </box>
              }
              footer={null}
            />
          )}
        </For>
      </box>
      <box class="network-wifi" orientation={Gtk.Orientation.VERTICAL} spacing={6} visible={showWifi}>
        <PopoverTitleBlock
          containerClass="network-wifi-header"
          titleClass="network-wifi-title"
          title="WIFI"
          xalign={0}
        />
        <PopoverScrollArea className="network-wifi-scroll" maxContentHeight={240}>
          <CollapsableList className="network-wifi-list" each={wifiListView}>
            {(entry) => {
              const panelKey = getAccessPointKey(entry) || entry.name || entry.id;
              const passwordValue = createComputed(() => passwords()[panelKey] ?? "");
              const setPasswordValue = (value: string) => {
                setPasswords((prev) => ({ ...prev, [panelKey]: value }));
              };
              const isOpen = panelOpenId.as((id) => id === panelKey);
              const isConnected = state.as((networkState) => {
                const current = networkState.wifi.info.currentAp;
                return isSameAccessPoint(current, entry);
              });
              const requiresPassword = createComputed(() => entry.requirePassword && !isConnected());

              const closePanel = () => {
                if (panelOpenId() === panelKey) {
                  setPanelOpenId(null);
                  setFrozenList(null);
                }
              };

              const submitPassword = () => {
                closePanel();
                connectToAp(entry, passwordValue());
                setPasswords((prev) => {
                  const next = { ...prev };
                  delete next[panelKey];
                  return next;
                });
              };

              const entryKey = getAccessPointKey(entry) || panelKey;
              const isPending = createComputed(() => pendingAccessPoints().has(entryKey));
              const statusLabel = createComputed(() => {
                const error = errorState();
                if (error && (!error.target || error.target === entryKey)) {
                  return error.label;
                }
                if (isPending()) return "- pending";
                if (isConnected()) return "- connected";
                return "";
              });
              const nameLabel = statusLabel.as((value) => {
                const name = entry.name || "Unknown";
                return value.length > 0 ? `${name} ${value}` : name;
              });

              const rowContent = (
                <box class="network-wifi-item" spacing={6}>
                  <label class="network-wifi-icon" label={getWifiSignalIcon(entry.strength)} />
                  <label
                    class="network-wifi-name"
                    label={nameLabel}
                    hexpand
                    xalign={0}
                    ellipsize={Pango.EllipsizeMode.END}
                    lines={1}
                  />
                  {entry.requirePassword ? (
                    <label class="network-wifi-lock" label={WIFI_LOCK} />
                  ) : null}
                </box>
              );

              const rowButton = (
                <button
                  class="network-wifi-item-button"
                  sensitive={isPending.as((value) => !value)}
                  onClicked={() => {
                    if (isPending()) return;

                    if (isConnected() || requiresPassword()) {
                      setPanelOpenId((current) => {
                        const next = current === panelKey ? null : panelKey;
                        if (next) setFrozenList(wifiList());
                        else setFrozenList(null);
                        return next;
                      });
                      return;
                    }

                    if (panelOpenId()) {
                      setPanelOpenId(null);
                      setFrozenList(null);
                    }

                    connectToAp(entry, null);
                  }}
                >
                  {rowContent}
                </button>
              );

              const details = !requiresPassword() && !isConnected()
                ? null
                : (
                    <box
                      class="network-wifi-password-inner"
                      orientation={Gtk.Orientation.VERTICAL}
                      spacing={8}
                    >
                      {isConnected() ? (
                        <button
                          class="network-wifi-popover-connect"
                          sensitive={isPending.as((value) => !value)}
                          onClicked={() => {
                            closePanel();
                            disconnectWifi(entry);
                          }}
                        >
                          <label label="Disconnect" />
                        </button>
                      ) : (
                        <>
                          <label class="network-wifi-popover-title" label="Connect to WIFI" xalign={0} />
                          <label class="network-wifi-popover-label" label="Password" xalign={0} />
                          <Gtk.PasswordEntry
                            class="network-wifi-popover-entry"
                            showPeekIcon={true}
                            placeholderText="Password"
                            text={passwordValue}
                            $={(self) => {
                              self.set_show_peek_icon(true);
                              self.connect("changed", () => setPasswordValue(self.text ?? ""));
                              self.connect("activate", () => submitPassword());
                            }}
                          />
                          <button
                            class="network-wifi-popover-connect"
                            sensitive={isPending.as((value) => !value)}
                            onClicked={() => submitPassword()}
                          >
                            <label label="Connect" />
                          </button>
                        </>
                      )}
                    </box>
                  );

              return (
                <CollapsableListItem
                  className="network-wifi-row"
                  header={rowButton}
                  details={details}
                  revealDetails={isOpen}
                  detailsClass="network-wifi-password"
                />
              );
            }}
          </CollapsableList>
        </PopoverScrollArea>
      </box>
    </WidgetPopover>
  );
}
