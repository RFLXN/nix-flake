{ settings ? [] }:
{ hyprLua, pkgs, lib, username, ... }:
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
      defaultLua = "hl.monitor(${hyprLua.toLua defaultSetup})";
      toggleLua = "hl.monitor(${hyprLua.toLua toggleSetup})";
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
        default_refresh="$(printf '%s' '${defaultSetup.mode}' | "$sed" -n 's/.*@\([0-9.]\+\).*/\1/p')"
        toggle_refresh="$(printf '%s' '${toggleSetup.mode}' | "$sed" -n 's/.*@\([0-9.]\+\).*/\1/p')"

        current_major="''${current_refresh%%.*}"
        default_major="''${default_refresh%%.*}"
        toggle_major="''${toggle_refresh%%.*}"

        if [ "$current_major" = "$toggle_major" ]; then
          target_lua=${lib.escapeShellArg defaultLua}
        elif [ "$current_major" = "$default_major" ]; then
          target_lua=${lib.escapeShellArg toggleLua}
        else
          target_lua=${lib.escapeShellArg toggleLua}
        fi

        "$hyprctl" eval "$target_lua" >/dev/null
      '';
    in {
      inherit key scriptName package;
    }
  ) settings;
in {
  assertions = lib.imap0 (
    index: entry: {
      assertion =
        entry ? defaultSetup
        && entry ? toggleSetup
        && lib.isAttrs entry.defaultSetup
        && lib.isAttrs entry.toggleSetup;
      message = "hyprland.keybinds.useToggleMonitorSetup: settings[${toString index}].defaultSetup and toggleSetup must be hl.monitor spec attrsets.";
    }
  ) settings;

  home-manager.users.${username} = {
    home.packages = map (toggle: toggle.package) toggles;

    wayland.windowManager.hyprland.settings.bind = map (
      toggle: hyprLua.execBind toggle.key "${toggle.package}/bin/${toggle.scriptName}"
    ) toggles;
  };
}
