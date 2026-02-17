import AstalApps from "gi://AstalApps?version=0.1";
import app from "ags/gtk4/app";
import { Astal, Gtk } from "ags/gtk4";
import Gdk from "gi://Gdk?version=4.0";
import GLib from "gi://GLib?version=2.0";
import Pango from "gi://Pango";
import { execAsync } from "ags/process";
import { For, createComputed, createState } from "gnim";

type LauncherEntry = AstalApps.Application;
type PendingAction = "logout" | "shutdown" | null;
type ConfirmAction = Exclude<PendingAction, null>;

const WINDOW_NAME = {
  launcher: "launcher",
  confirm: "launcher-confirm",
} as const;
type WindowName = (typeof WINDOW_NAME)[keyof typeof WINDOW_NAME];

const CONFIRM_META: Record<ConfirmAction, { title: string; subtitle: string; cta: string; glyph: string }> = {
  logout: {
    title: "Logout",
    subtitle: "Did you want to log out from this session?",
    cta: "Logout now",
    glyph: "󰍃",
  },
  shutdown: {
    title: "Shutdown",
    subtitle: "Did you want to shut down the system?",
    cta: "Shutdown now",
    glyph: "󰐥",
  },
};

const apps = AstalApps.Apps.new();
apps.reload();
const MAX_RESULTS = 32;

const [pendingAction, setPendingAction] = createState<PendingAction>(null);

function getWindow(name: WindowName) {
  return app.get_window(name);
}

function hideLauncher() {
  const launcherWindow = getWindow(WINDOW_NAME.launcher);
  if (!launcherWindow) return;
  launcherWindow.visible = false;
}

function showLauncher() {
  const launcherWindow = getWindow(WINDOW_NAME.launcher);
  if (!launcherWindow) return;
  launcherWindow.visible = true;
}

function hideConfirmationWindow() {
  const confirmationWindow = getWindow(WINDOW_NAME.confirm);
  if (!confirmationWindow) return;
  confirmationWindow.visible = false;
}

function showConfirmationWindow() {
  const confirmationWindow = getWindow(WINDOW_NAME.confirm);
  if (!confirmationWindow) return;
  confirmationWindow.visible = true;
}

function openConfirmation(action: ConfirmAction) {
  setPendingAction(action);
  hideLauncher();
  showConfirmationWindow();
}

function selectedConfirmAction(): ConfirmAction {
  return pendingAction() ?? "shutdown";
}

function launch(entry: LauncherEntry) {
  try {
    const launched = entry.launch();
    if (!launched) {
      console.error(`launcher: failed to launch app "${entry.name || entry.entry}"`);
      return;
    }
    hideLauncher();
  } catch (error) {
    console.error("launcher: failed to launch app", error);
  }
}

async function runFirstSuccessful(commands: string[][]): Promise<boolean> {
  for (const command of commands) {
    try {
      await execAsync(command);
      return true;
    } catch {
      // continue trying fallbacks
    }
  }
  return false;
}

async function logoutSession() {
  hideLauncher();
  hideConfirmationWindow();

  const sessionId = GLib.getenv("XDG_SESSION_ID");
  const commands: string[][] = [["uwsm", "stop"]];
  if (sessionId && sessionId.length > 0) {
    commands.push(["loginctl", "terminate-session", sessionId]);
  }
  commands.push(["hyprctl", "dispatch", "exit"]);

  const ok = await runFirstSuccessful(commands);
  if (!ok) {
    console.error("launcher: failed to logout session");
  }
}

async function shutdownSystem() {
  hideLauncher();
  hideConfirmationWindow();
  const ok = await runFirstSuccessful([
    ["systemctl", "poweroff"],
    ["loginctl", "poweroff"],
  ]);
  if (!ok) {
    console.error("launcher: failed to shutdown");
  }
}

function cancelConfirmation(reopenLauncher: boolean) {
  setPendingAction(null);
  hideConfirmationWindow();
  if (reopenLauncher) showLauncher();
}

async function confirmPendingAction() {
  const action = pendingAction();
  if (!action) return;

  setPendingAction(null);
  if (action === "logout") {
    await logoutSession();
    return;
  }

  await shutdownSystem();
}

export default function LauncherWindow() {
  const { TOP, LEFT } = Astal.WindowAnchor;
  const [query, setQuery] = createState("");
  let searchEntry: Gtk.Entry | null = null;

  const results = createComputed(() => {
    const term = query().trim();
    const list = term.length > 0 ? apps.fuzzy_query(term) : apps.list;

    return list
      .slice(0, MAX_RESULTS)
      .filter((entry) => Boolean(entry.name?.length || entry.entry?.length));
  });

  const showEmpty = createComputed(() => query().trim().length > 0 && results().length === 0);

  const onWindowVisibilityChanged = (visible: boolean) => {
    if (!visible) {
      setQuery("");
      return;
    }

    setQuery("");
    if (searchEntry) {
      searchEntry.grab_focus();
      searchEntry.set_position(-1);
    }
  };

  return (
    <window
      name={WINDOW_NAME.launcher}
      class="launcher-window"
      visible={false}
      anchor={TOP | LEFT}
      layer={Astal.Layer.OVERLAY}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.ON_DEMAND}
      application={app}
      $={(self) => {
        const handleVisibility = () => onWindowVisibilityChanged(self.visible);
        self.connect("notify::visible", () => handleVisibility());
        self.connect("notify::is-active", () => {
          const active =
            typeof (self as { is_active?: boolean }).is_active === "boolean"
              ? (self as { is_active: boolean }).is_active
              : Boolean((self as { isActive?: boolean }).isActive);
          if (self.visible && !active) {
            hideLauncher();
          }
        });

        const keyController = new Gtk.EventControllerKey();
        keyController.connect("key-pressed", (_controller, keyval) => {
          if (keyval === Gdk.KEY_Escape) {
            hideLauncher();
            return true;
          }
          return false;
        });
        self.add_controller(keyController);
      }}
    >
      <box
        class="launcher-shell"
        orientation={Gtk.Orientation.VERTICAL}
        spacing={0}
        halign={Gtk.Align.START}
        valign={Gtk.Align.START}
        marginTop={44}
        marginStart={8}
      >
        <box class="launcher-menu" orientation={Gtk.Orientation.VERTICAL} spacing={8}>
          <box class="launcher-menu-header" spacing={8}>
            <label class="launcher-menu-icon" label="" />
            <box orientation={Gtk.Orientation.VERTICAL} spacing={0}>
              <label class="launcher-title" label="Launcher" xalign={0} />
              <label class="launcher-subtitle" label="Applications" xalign={0} />
            </box>
          </box>
          <Gtk.Entry
            class="launcher-search"
            hexpand
            placeholderText="Search apps"
            text={query}
            $={(self) => {
              searchEntry = self;
              self.connect("changed", () => setQuery(self.text ?? ""));
              self.connect("activate", () => {
                const first = results()[0];
                if (first) launch(first);
              });
            }}
          />
          <Gtk.Separator class="launcher-separator" orientation={Gtk.Orientation.HORIZONTAL} />
          <scrolledwindow
            class="launcher-scroll"
            vscrollbarPolicy={Gtk.PolicyType.AUTOMATIC}
            hscrollbarPolicy={Gtk.PolicyType.NEVER}
            propagateNaturalHeight={true}
            minContentHeight={0}
            maxContentHeight={420}
          >
            <box class="launcher-list" orientation={Gtk.Orientation.VERTICAL} spacing={2}>
              <For each={results}>
                {(entry) => (
                  <button class="launcher-item" onClicked={() => launch(entry)}>
                    <box class="launcher-item-inner" spacing={8}>
                      {entry.iconName ? (
                        <image class="launcher-item-icon" iconName={entry.iconName} pixelSize={18} />
                      ) : (
                        <label class="launcher-item-icon" label="󰀻" />
                      )}
                      <box
                        class="launcher-item-text"
                        orientation={Gtk.Orientation.VERTICAL}
                        spacing={1}
                        hexpand
                      >
                        <label
                          class="launcher-item-name"
                          label={entry.name || entry.entry || "Application"}
                          xalign={0}
                          ellipsize={Pango.EllipsizeMode.END}
                          lines={1}
                        />
                        <label
                          class="launcher-item-desc"
                          label={entry.description || entry.executable || ""}
                          visible={Boolean(entry.description || entry.executable)}
                          xalign={0}
                          ellipsize={Pango.EllipsizeMode.END}
                          lines={1}
                        />
                      </box>
                    </box>
                  </button>
                )}
              </For>
            </box>
          </scrolledwindow>
          <box class="launcher-empty" visible={showEmpty}>
            <label label="No apps found" />
          </box>
          <box class="launcher-footer">
            <box class="launcher-actions" spacing={6} hexpand halign={Gtk.Align.END}>
              <button
                class="launcher-action launcher-action-logout"
                tooltipText="Logout"
                onClicked={() => openConfirmation("logout")}
              >
                <label class="launcher-action-glyph" label="󰍃" />
              </button>
              <button
                class="launcher-action launcher-action-shutdown"
                tooltipText="Shutdown"
                onClicked={() => openConfirmation("shutdown")}
              >
                <label class="launcher-action-glyph" label="󰐥" />
              </button>
            </box>
          </box>
        </box>
      </box>
    </window>
  );
}

export function LauncherConfirmWindow() {
  const { TOP, LEFT, RIGHT, BOTTOM } = Astal.WindowAnchor;

  const confirmationTitle = createComputed(() => CONFIRM_META[selectedConfirmAction()].title);
  const confirmationSubtitle = createComputed(() => CONFIRM_META[selectedConfirmAction()].subtitle);
  const confirmationActionLabel = createComputed(() => CONFIRM_META[selectedConfirmAction()].cta);
  const confirmationActionGlyph = createComputed(() => CONFIRM_META[selectedConfirmAction()].glyph);

  return (
    <window
      name={WINDOW_NAME.confirm}
      class="launcher-confirm-window"
      visible={false}
      anchor={TOP | LEFT | RIGHT | BOTTOM}
      layer={Astal.Layer.OVERLAY}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.ON_DEMAND}
      application={app}
      $={(self) => {
        self.connect("notify::visible", () => {
          if (!self.visible) {
            setPendingAction(null);
          }
        });

        const keyController = new Gtk.EventControllerKey();
        keyController.connect("key-pressed", (_controller, keyval) => {
          if (keyval === Gdk.KEY_Escape) {
            cancelConfirmation(true);
            return true;
          }
          return false;
        });
        self.add_controller(keyController);
      }}
    >
      <box
        class="launcher-confirm-shell"
        orientation={Gtk.Orientation.VERTICAL}
        spacing={0}
        hexpand
        vexpand
        halign={Gtk.Align.FILL}
        valign={Gtk.Align.FILL}
      >
        <box
          class="launcher-confirm-stage"
          orientation={Gtk.Orientation.VERTICAL}
          spacing={0}
          hexpand
          vexpand
          halign={Gtk.Align.CENTER}
          valign={Gtk.Align.CENTER}
        >
          <box class="launcher-confirm-content" orientation={Gtk.Orientation.VERTICAL} spacing={14}>
            <label class="launcher-confirm-title" label={confirmationTitle} />
            <label class="launcher-confirm-subtitle" label={confirmationSubtitle} />
            <box class="launcher-confirm-choices" spacing={24} halign={Gtk.Align.CENTER}>
              <box class="launcher-confirm-choice" orientation={Gtk.Orientation.VERTICAL} spacing={6}>
                <button
                  class="launcher-confirm-circle launcher-confirm-circle-cancel"
                  onClicked={() => cancelConfirmation(true)}
                >
                  <label class="launcher-confirm-circle-icon" label="󰅖" />
                </button>
                <label class="launcher-confirm-choice-label" label="Cancel" />
              </box>
              <box class="launcher-confirm-choice" orientation={Gtk.Orientation.VERTICAL} spacing={6}>
                <button
                  class="launcher-confirm-circle launcher-confirm-circle-accept"
                  onClicked={() => void confirmPendingAction()}
                >
                  <label class="launcher-confirm-circle-icon" label={confirmationActionGlyph} />
                </button>
                <label
                  class="launcher-confirm-choice-label launcher-confirm-choice-label-accept"
                  label={confirmationActionLabel}
                />
              </box>
            </box>
          </box>
        </box>
      </box>
    </window>
  );
}
