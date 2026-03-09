{ settings ? [] }:
{ pkgs, lib, username, ... }:
let
  toggles = lib.imap0 (
    index:
    {
      monitorName,
      defaultSetup,
      toggleSetup,
      key ? "SUPER SHIFT, P",
    }:
    let
      scriptName = "hypr-toggle-monitor-setup-${toString index}-${pkgs.lib.strings.sanitizeDerivationName monitorName}";
      package = pkgs.writeShellScriptBin scriptName ''
        set -euo pipefail

        hyprctl='${pkgs.hyprland}/bin/hyprctl'
        awk='${pkgs.gawk}/bin/awk'
        sed='${pkgs.gnused}/bin/sed'

        current_mode_line="$("$hyprctl" monitors all | "$awk" -v monitor='${monitorName}' '$1 == "Monitor" && $2 == monitor { getline; print; exit }')"
        if [ -z "$current_mode_line" ]; then
          exit 1
        fi

        current_refresh="$(printf '%s' "$current_mode_line" | "$sed" -n 's/.*@\([0-9.]\+\).*/\1/p')"
        default_refresh="$(printf '%s' '${defaultSetup}' | "$sed" -n 's/.*@\([0-9.]\+\).*/\1/p')"
        toggle_refresh="$(printf '%s' '${toggleSetup}' | "$sed" -n 's/.*@\([0-9.]\+\).*/\1/p')"

        current_major="''${current_refresh%%.*}"
        default_major="''${default_refresh%%.*}"
        toggle_major="''${toggle_refresh%%.*}"

        if [ "$current_major" = "$toggle_major" ]; then
          target='${defaultSetup}'
        elif [ "$current_major" = "$default_major" ]; then
          target='${toggleSetup}'
        else
          target='${toggleSetup}'
        fi

        "$hyprctl" keyword monitor "$target" >/dev/null
      '';
    in {
      inherit key scriptName package;
    }
  ) settings;
in {
  home-manager.users.${username} = {
    home.packages = map (toggle: toggle.package) toggles;

    wayland.windowManager.hyprland.settings.bind = map (
      toggle: "${toggle.key}, exec, ${toggle.package}/bin/${toggle.scriptName}"
    ) toggles;
  };
}
