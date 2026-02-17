import { Astal, Gtk } from "ags/gtk4";
import Clock from "./widgets/clock";
import Launcher from "./widgets/launcher";
import LauncherWindow, { LauncherConfirmWindow } from "./widgets/launcher/window";
import Bluetooth from "./widgets/bluetooth";
import Notification from "./widgets/notification";
import NotificationToasts from "./widgets/notification/toasts";
import Network from "./widgets/network";
import Tray from "./widgets/tray";
import Volume from "./widgets/volume";
import Workspaces from "./widgets/workspaces";

export default function Layout() {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

  return [
    <window
      class="bar"
      visible
      anchor={TOP | LEFT | RIGHT}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      layer={Astal.Layer.TOP}
    >
      <centerbox
        class="bar-inner"
        hexpand
        startWidget={
          (
            <box class="bar-left">
              <Launcher />
              <Notification />
              <Tray />
            </box>
          ) as unknown as Gtk.Widget
        }
        centerWidget={
          (
            <box class="bar-center">
              <Workspaces />
            </box>
          ) as unknown as Gtk.Widget
        }
        endWidget={
          (
            <box class="bar-right">
              <Volume />
              <Bluetooth />
              <Network />
              <Clock format="%Y-%m-%d %I:%M:%S %p" />
            </box>
          ) as unknown as Gtk.Widget
        }
      />
    </window>,
    <LauncherWindow />,
    <LauncherConfirmWindow />,
    <NotificationToasts />,
  ];
}
