{ key ? "SUPER, D" }:
{ pkgs, username, ... }:
let
  toggleLauncher = pkgs.writeShellScriptBin "rflxn-shell-launcher-toggle" ''
    set -euo pipefail

    pid="$(${pkgs.systemd}/bin/systemctl --user show rflxn-shell.service -p MainPID --value 2>/dev/null || true)"
    if [ -z "$pid" ] || [ "$pid" = "0" ]; then
      exit 0
    fi

    if command -v quickshell >/dev/null 2>&1; then
      quickshell="$(command -v quickshell)"
    elif [ -x "/etc/profiles/per-user/${username}/bin/quickshell" ]; then
      quickshell="/etc/profiles/per-user/${username}/bin/quickshell"
    else
      exit 127
    fi

    exec "$quickshell" ipc --pid "$pid" call launcher toggle
  '';
in
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings.bind = [
    "${key}, exec, ${toggleLauncher}/bin/rflxn-shell-launcher-toggle"
  ];
}
