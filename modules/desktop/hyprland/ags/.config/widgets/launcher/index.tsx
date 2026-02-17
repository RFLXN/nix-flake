import app from "ags/gtk4/app";
import GLib from "gi://GLib?version=2.0";
import { SimpleWidgetButton } from "../../components/outer";

const NIXOS_ICON = GLib.build_filenamev([
  GLib.get_user_config_dir(),
  "ags",
  "assets",
  "nix-snowflake.svg",
]);

function toggleLauncher() {
  try {
    app.toggle_window("launcher");
  } catch (error) {
    console.error("launcher: failed to toggle launcher window", error);
  }
}

export default function Launcher() {
  return (
    <SimpleWidgetButton
      className="launcher"
      onClicked={toggleLauncher}
      child={<image file={NIXOS_ICON} pixelSize={18} />}
    />
  );
}
