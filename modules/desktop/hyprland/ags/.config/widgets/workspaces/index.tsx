import AstalHyprland from "gi://AstalHyprland?version=0.1";
import { Accessor, For } from "gnim";

type WorkspaceItem = {
  id: number;
  icon: string;
  active: boolean;
  className: string;
};

const hypr = AstalHyprland.Hyprland.get_default();

function monitorId(monitor: AstalHyprland.Monitor | null | undefined): number {
  return typeof monitor?.id === "number" ? monitor.id : Number.MAX_SAFE_INTEGER;
}

function getTargetMonitor(): AstalHyprland.Monitor | null {
  if (!hypr) return null;
  const monitors = hypr.monitors ?? [];
  if (monitors.length === 0) return null;

  const focusedMonitor = hypr.focusedMonitor;
  if (focusedMonitor && monitors.some((monitor) => monitor.id === focusedMonitor.id)) {
    return focusedMonitor;
  }

  const focusedWorkspaceMonitor = hypr.focusedWorkspace?.monitor;
  if (
    focusedWorkspaceMonitor &&
    monitors.some((monitor) => monitor.id === focusedWorkspaceMonitor.id)
  ) {
    return focusedWorkspaceMonitor;
  }

  return [...monitors].sort((a, b) => monitorId(a) - monitorId(b))[0] ?? null;
}

function buildItems(): WorkspaceItem[] {
  if (!hypr) return [];
  const targetMonitor = getTargetMonitor();
  if (!targetMonitor) return [];

  const focusedId = hypr.focusedWorkspace?.id ?? -1;

  return (hypr.workspaces ?? [])
    .filter((ws) => ws.id > 0)
    .filter((ws) => ws.monitor?.id === targetMonitor.id)
    .sort((a, b) => a.id - b.id)
    .map((ws) => {
      const active = ws.id === focusedId;
      const hasClients = (ws.clients?.length ?? 0) > 0;
      const icon = active ? "" : hasClients ? "󰪥" : "";
      const className = active ? "workspace active" : hasClients ? "workspace occupied" : "workspace empty";
      return { id: ws.id, icon, active, className };
    });
}

const emptyItems = new Accessor<WorkspaceItem[]>(() => [], () => () => {});

const workspaceItems = hypr
  ? new Accessor<WorkspaceItem[]>(
      () => buildItems(),
      (notify) => {
        const signals = [
          "notify::workspaces",
          "notify::focused-workspace",
          "notify::focused-monitor",
          "workspace-added",
          "workspace-removed",
          "client-added",
          "client-removed",
          "client-moved",
          "monitor-added",
          "monitor-removed",
        ] as const;

        const ids = signals.map((signal) => hypr.connect(signal, () => notify()));
        return () => ids.forEach((id) => hypr.disconnect(id));
      },
    )
  : emptyItems;

export default function Workspaces() {
  const focusWorkspace = (id: number) => {
    if (!hypr) return;
    hypr.dispatch("workspace", `${id}`);
  };

  return (
    <box class="widget workspaces" spacing={6}>
      <For each={workspaceItems}>
        {(item) => (
          <button class={item.className} onClicked={() => focusWorkspace(item.id)}>
            <label label={item.icon} xalign={0.5} />
          </button>
        )}
      </For>
    </box>
  );
}
