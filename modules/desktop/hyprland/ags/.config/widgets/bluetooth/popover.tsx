import AstalBluetooth from "gi://AstalBluetooth?version=0.1";
import { Gtk } from "ags/gtk4";
import GLib from "gi://GLib";
import { Accessor, createComputed, createConnection, createState } from "gnim";
import { CollapsableList, CollapsableListItem } from "../../components/collapsable-list";
import { PopoverEmptyState, PopoverScrollArea, WidgetPopover } from "../../components/popover";

type BluetoothPopoverProps = {
  open: Accessor<boolean>;
  flip: Accessor<boolean>;
};

type DeviceKind = "audio" | "mouse" | "keyboard" | "other";

type DeviceSnapshot = {
  device: AstalBluetooth.Device;
  name: string;
  address: string;
  paired: boolean;
  connected: boolean;
  connecting: boolean;
  trusted: boolean;
  kind: DeviceKind;
};

const DEVICE_ICONS: Record<DeviceKind, string> = {
  audio: "󰗾",
  mouse: "󰦋",
  keyboard: "󰌌",
  other: "󰂱",
};

const bluetooth = AstalBluetooth.Bluetooth.get_default();

const emptyBool = new Accessor<boolean>(() => false, () => () => {});
const emptyAdapter = new Accessor<AstalBluetooth.Adapter | null>(() => null, () => () => {});
const emptyDevices = new Accessor<DeviceSnapshot[]>(() => [], () => () => {});

function deviceKind(device: AstalBluetooth.Device): DeviceKind {
  const icon = (device.icon ?? "").toLowerCase();
  if (
    icon.includes("audio") ||
    icon.includes("headset") ||
    icon.includes("headphone") ||
    icon.includes("speaker")
  ) {
    return "audio";
  }
  if (icon.includes("mouse")) return "mouse";
  if (icon.includes("keyboard")) return "keyboard";
  return "other";
}

function deviceLabel(device: AstalBluetooth.Device): string {
  return device.alias || device.name || "Bluetooth Device";
}

function runDeviceOp(
  run: (cb: (self: AstalBluetooth.Device | null, res: unknown) => void) => void,
  finish: (self: AstalBluetooth.Device, res: unknown) => void,
): Promise<void> {
  return new Promise((resolve, reject) => {
    run((self, res) => {
      try {
        if (!self) {
          reject(new Error("bluetooth: operation returned null device"));
          return;
        }
        finish(self, res);
        resolve();
      } catch (error) {
        reject(error);
      }
    });
  });
}

function snapshotDevice(device: AstalBluetooth.Device): DeviceSnapshot {
  return {
    device,
    name: deviceLabel(device),
    address: device.address ?? "",
    paired: device.paired,
    connected: device.connected,
    connecting: device.connecting,
    trusted: device.trusted,
    kind: deviceKind(device),
  };
}

const powered = bluetooth
  ? createConnection(
      bluetooth.isPowered,
      [bluetooth, "notify::is-powered", () => bluetooth.isPowered],
      [bluetooth, "notify::adapter", () => bluetooth.isPowered],
      [bluetooth, "notify::adapters", () => bluetooth.isPowered],
    )
  : emptyBool;

const adapter = bluetooth
  ? createConnection(
      bluetooth.adapter,
      [bluetooth, "notify::adapter", () => bluetooth.adapter],
      [bluetooth, "notify::adapters", () => bluetooth.adapter],
    )
  : emptyAdapter;

const deviceSnapshots = bluetooth
  ? new Accessor<DeviceSnapshot[]>(
      () => {
        if (!bluetooth.isPowered) return [];
        return (bluetooth.devices ?? []).map(snapshotDevice);
      },
      (notify) => {
        const deviceSignalIds = new Map<AstalBluetooth.Device, number[]>();

        const disconnectDeviceSignals = (device: AstalBluetooth.Device) => {
          const ids = deviceSignalIds.get(device);
          if (!ids) return;
          ids.forEach((id) => device.disconnect(id));
          deviceSignalIds.delete(device);
        };

        const connectDeviceSignals = (device: AstalBluetooth.Device) => {
          const ids = [
            device.connect("notify::connected", () => notify()),
            device.connect("notify::connecting", () => notify()),
            device.connect("notify::paired", () => notify()),
            device.connect("notify::trusted", () => notify()),
            device.connect("notify::alias", () => notify()),
            device.connect("notify::name", () => notify()),
            device.connect("notify::icon", () => notify()),
            device.connect("notify::address", () => notify()),
          ];
          deviceSignalIds.set(device, ids);
        };

        const syncDeviceSignals = () => {
          const devices = bluetooth.devices ?? [];
          const nextSet = new Set(devices);

          for (const device of Array.from(deviceSignalIds.keys())) {
            if (!nextSet.has(device)) {
              disconnectDeviceSignals(device);
            }
          }

          for (const device of devices) {
            if (!deviceSignalIds.has(device)) {
              connectDeviceSignals(device);
            }
          }

          notify();
        };

        const rootSignals = [
          bluetooth.connect("notify::is-powered", () => notify()),
          bluetooth.connect("notify::devices", () => syncDeviceSignals()),
          bluetooth.connect("device-added", () => syncDeviceSignals()),
          bluetooth.connect("device-removed", () => syncDeviceSignals()),
        ];

        syncDeviceSignals();

        return () => {
          rootSignals.forEach((id) => bluetooth.disconnect(id));
          for (const device of Array.from(deviceSignalIds.keys())) {
            disconnectDeviceSignals(device);
          }
        };
      },
    )
  : emptyDevices;

export default function BluetoothPopover({ open, flip }: BluetoothPopoverProps) {
  const [hiddenDevices, setHiddenDevices] = createState<Set<string>>(new Set());
  const [openDeviceId, setOpenDeviceId] = createState<string | null>(null);
  const [trustOverrides, setTrustOverrides] = createState<Record<string, boolean>>({});
  const [pendingRows, setPendingRows] = createState<Set<string>>(new Set());

  const enabledLabel = powered.as((value) => (value ? "Disable" : "Enable"));
  const deviceList = createComputed(() => {
    if (!powered()) return [];
    const list = deviceSnapshots();
    const hidden = hiddenDevices();

    return [...list]
      .sort((a, b) => {
        if (a.connected !== b.connected) return a.connected ? -1 : 1;
        return a.name.localeCompare(b.name);
      })
      .filter((item) => !item.address || !hidden.has(item.address));
  });

  const showDisabled = powered.as((value) => !value);
  const showEmpty = createComputed(() => powered() && deviceList().length === 0);
  const showDevices = createComputed(() => powered() && deviceList().length > 0);
  const isDiscovering = bluetooth
    ? new Accessor<boolean>(
        () => adapter()?.discovering ?? false,
        (notify) => {
          let current = adapter();
          let currentId: number | null = null;

          const attachAdapter = () => {
            if (current && currentId !== null) current.disconnect(currentId);
            current = adapter();
            currentId = current ? current.connect("notify::discovering", () => notify()) : null;
            notify();
          };

          const rootIds = [
            bluetooth.connect("notify::adapter", () => attachAdapter()),
            bluetooth.connect("notify::adapters", () => attachAdapter()),
          ];

          attachAdapter();

          return () => {
            if (current && currentId !== null) current.disconnect(currentId);
            rootIds.forEach((id) => bluetooth.disconnect(id));
          };
        },
      )
    : emptyBool;

  const searchLabel = isDiscovering.as((value) => (value ? "Searching..." : "Search"));
  const searchEnabled = createComputed(() => powered() && !isDiscovering());

  createComputed(() => {
    const validIds = new Set(deviceList().map((item) => item.address || item.name));

    const opened = openDeviceId();
    if (opened && !validIds.has(opened)) {
      setOpenDeviceId(null);
    }

    const overrides = trustOverrides();
    const staleKeys = Object.keys(overrides).filter((key) => !validIds.has(key));
    if (staleKeys.length > 0) {
      setTrustOverrides((prev) => {
        const next = { ...prev };
        staleKeys.forEach((key) => delete next[key]);
        return next;
      });
    }
  });

  const runRowOperation = async (rowId: string, run: () => Promise<void>) => {
    if (!rowId) {
      await run();
      return;
    }
    if (pendingRows().has(rowId)) return;

    setPendingRows((prev) => {
      const next = new Set(prev);
      next.add(rowId);
      return next;
    });

    try {
      await run();
    } finally {
      setPendingRows((prev) => {
        if (!prev.has(rowId)) return prev;
        const next = new Set(prev);
        next.delete(rowId);
        return next;
      });
    }
  };

  const togglePower = () => {
    if (!bluetooth) return;
    bluetooth.toggle();
  };

  const toggleDiscovery = () => {
    const current = adapter();
    if (!current) return;
    if (current.discovering) {
      current.stop_discovery();
    } else {
      current.start_discovery();
    }
  };

  return (
    <WidgetPopover
      popoverClass="bluetooth-popover"
      menuClassName="bluetooth-menu"
      open={open}
      flip={flip}
    >
      <box class="bluetooth-header" spacing={8}>
        <label class="bluetooth-header-title" label="Bluetooth" hexpand xalign={0} />
        <button class="bluetooth-header-action" onClicked={togglePower}>
          <label label={enabledLabel} />
        </button>
      </box>
      <Gtk.Separator orientation={Gtk.Orientation.HORIZONTAL} />
      <box class="bluetooth-subheader" spacing={8}>
        <label class="bluetooth-subtitle" label="Devices" hexpand xalign={0} />
        <button class="bluetooth-header-action" sensitive={searchEnabled} onClicked={toggleDiscovery}>
          <label label={searchLabel} />
        </button>
      </box>
      <PopoverEmptyState
        className="bluetooth-empty"
        visible={showDisabled}
        label="Bluetooth is disabled"
      />
      <PopoverEmptyState className="bluetooth-empty" visible={showEmpty} label="no devices found" />
      <PopoverScrollArea className="bluetooth-scroll" visible={showDevices} maxContentHeight={240}>
        <CollapsableList className="bluetooth-devices" each={deviceList}>
          {(item) => {
            const icon = DEVICE_ICONS[item.kind] ?? DEVICE_ICONS.other;
            const device = item.device;
            const rowId = item.address || item.name;
            const canAct = createComputed(
              () => powered() && !item.connecting && !pendingRows().has(rowId),
            );
            const isOpen = createComputed(() => openDeviceId() === rowId);
            const trustChecked = createComputed(() => {
              const overrides = trustOverrides();
              if (rowId in overrides) return overrides[rowId];
              return item.trusted;
            });
            const connectLabel = createComputed(() => {
              if (item.connected) return "Disconnect";
              if (item.paired) return "Connect";
              return "Pair";
            });

            const onPair = () => {
              runRowOperation(rowId, async () => {
                try {
                  device.pair();
                } catch (error) {
                  console.error("bluetooth: pair failed", error);
                }
              });
            };

            const onConnect = async () => {
              await runRowOperation(rowId, async () => {
                try {
                  await runDeviceOp(
                    (cb) => device.connect_device(cb),
                    (self, res) => self.connect_device_finish(res as never),
                  );
                } catch (error) {
                  console.error("bluetooth: connect failed", error);
                }
              });
            };

            const onDisconnect = async () => {
              await runRowOperation(rowId, async () => {
                try {
                  await runDeviceOp(
                    (cb) => device.disconnect_device(cb),
                    (self, res) => self.disconnect_device_finish(res as never),
                  );
                } catch (error) {
                  console.error("bluetooth: disconnect failed", error);
                }
              });
            };

            const applyTrustIfNeeded = () => {
              if (item.connected) return;
              if (!trustChecked() && device.trusted) {
                device.trusted = false;
                return;
              }
              if (trustChecked() && !device.trusted) {
                device.trusted = true;
              }
            };

            const onForget = () => {
              if (!device.paired) return;
              const current = bluetooth?.adapter ?? (bluetooth?.adapters?.[0] ?? null);
              if (!current) return;

              runRowOperation(rowId, async () => {
                try {
                  current.remove_device(device);
                  const address = device.address ?? "";
                  if (address) {
                    setHiddenDevices((prev) => {
                      const next = new Set(prev);
                      next.add(address);
                      return next;
                    });

                    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 10000, () => {
                      setHiddenDevices((prev) => {
                        if (!prev.has(address)) return prev;
                        const next = new Set(prev);
                        next.delete(address);
                        return next;
                      });
                      return GLib.SOURCE_REMOVE;
                    });
                  }
                } catch (error) {
                  const message = String(error);
                  if (!message.includes("DoesNotExist")) {
                    console.error("bluetooth: remove failed", error);
                  }
                }
              });
            };

            const header = (
              <box class="bluetooth-device-header" spacing={6}>
                <button
                  class="bluetooth-device-toggle"
                  hexpand
                  onClicked={() => setOpenDeviceId((current) => (current === rowId ? null : rowId))}
                >
                  <box class="bluetooth-device" spacing={6}>
                    <label class="bluetooth-device-icon" label={icon} />
                    <label class="bluetooth-device-name" label={item.name} hexpand xalign={0} />
                  </box>
                </button>
                {item.paired ? (
                  <button class="bluetooth-device-forget" sensitive={canAct} onClicked={onForget}>
                    <label label="" />
                  </button>
                ) : null}
              </box>
            );

            const details = (
              <box class="bluetooth-device-controls" spacing={8}>
                <button
                  class="bluetooth-device-action compact"
                  sensitive={canAct}
                  hexpand
                  halign={Gtk.Align.FILL}
                  onClicked={() => {
                    applyTrustIfNeeded();
                    if (rowId) {
                      setTrustOverrides((prev) => {
                        if (!(rowId in prev)) return prev;
                        const next = { ...prev };
                        delete next[rowId];
                        return next;
                      });
                    }

                    if (!item.paired) {
                      onPair();
                      return;
                    }
                    if (item.connected) {
                      onDisconnect();
                      return;
                    }
                    onConnect();
                  }}
                >
                  <label label={connectLabel} />
                </button>
                {!item.connected ? (
                  <Gtk.CheckButton
                    class="bluetooth-device-trust"
                    active={trustChecked}
                    sensitive={canAct}
                    halign={Gtk.Align.END}
                    onToggled={(self) => {
                      if (!rowId) return;
                      setTrustOverrides((prev) => ({
                        ...prev,
                        [rowId]: self.active,
                      }));
                    }}
                    label="Trust this device"
                  />
                ) : null}
              </box>
            );

            return (
              <CollapsableListItem
                className="bluetooth-device-row"
                header={header}
                details={details}
                revealDetails={isOpen}
                detailsClass="bluetooth-device-details"
              />
            );
          }}
        </CollapsableList>
      </PopoverScrollArea>
    </WidgetPopover>
  );
}
