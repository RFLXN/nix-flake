import AstalHyprland from "gi://AstalHyprland?version=0.1";
import GLib from "gi://GLib";
import { Accessor } from "gnim";

const hypr = AstalHyprland.get_default();

const emptyState = new Accessor<AstalHyprland.Fullscreen>(
  () => AstalHyprland.Fullscreen.NONE,
  () => () => {},
);

let currentFullscreen = AstalHyprland.Fullscreen.NONE;

export const focusedFullscreen = hypr
  ? new Accessor<AstalHyprland.Fullscreen>(
      () => currentFullscreen,
      (notify) => {
        let client = hypr.focusedClient;
        let clientId: number | null = null;
        let notifyId: number | null = null;

        const scheduleNotify = () => {
          if (notifyId !== null) return;
          notifyId = GLib.idle_add(GLib.PRIORITY_DEFAULT, () => {
            notifyId = null;
            notify();
            return GLib.SOURCE_REMOVE;
          });
        };

        const update = () => {
          currentFullscreen = client?.fullscreen ?? AstalHyprland.Fullscreen.NONE;
          scheduleNotify();
        };

        const attachClient = () => {
          if (client && clientId !== null) client.disconnect(clientId);
          client = hypr.focusedClient;
          clientId = client ? client.connect("notify::fullscreen", update) : null;
          update();
        };

        const hyprId = hypr.connect("notify::focused-client", attachClient);
        attachClient();

        return () => {
          if (client && clientId !== null) client.disconnect(clientId);
          hypr.disconnect(hyprId);
        };
      },
    )
  : emptyState;

export const isFocusedFullscreen = focusedFullscreen.as(
  (state) => state === AstalHyprland.Fullscreen.FULLSCREEN,
);

export const isFocusedMaximized = focusedFullscreen.as(
  (state) => state === AstalHyprland.Fullscreen.MAXIMIZED,
);
