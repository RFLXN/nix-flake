{ settings ? [] }:
{ config, hyprLua, pkgs, lib, username, ... }:
let
  # Rounded refresh rate from an hl.monitor mode such as "3456x2160@120" or
  # "1920x1080@59.94"; null when the mode carries no rate.
  refreshOf =
    setup:
    let
      mode = setup.mode or null;
      rate = if lib.isString mode then builtins.match ".*@([0-9]+(\\.[0-9]+)?)" mode else null;
    in
    if rate == null then null else builtins.floor (builtins.fromJSON (builtins.head rate) + 0.5);

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
      scriptName = "hypr-toggle-monitor-setup-${toString index}-${lib.strings.sanitizeDerivationName monitorName}";
      package = pkgs.writeShellScriptBin scriptName ''
        set -euo pipefail

        hyprctl='${config.programs.hyprland.package}/bin/hyprctl'
        jq='${pkgs.jq}/bin/jq'

        # Panels report rates like 59.94 or 119.88, so compare rounded values.
        current_refresh="$("$hyprctl" -j monitors all | "$jq" -r --arg monitor ${lib.escapeShellArg monitorName} \
          'first(.[] | select(.name == $monitor) | .refreshRate | round) // empty')"
        if [ -z "$current_refresh" ]; then
          exit 1
        fi

        if [ "$current_refresh" = ${lib.escapeShellArg (toString (refreshOf toggleSetup))} ]; then
          target_lua=${lib.escapeShellArg defaultLua}
        else
          target_lua=${lib.escapeShellArg toggleLua}
        fi

        "$hyprctl" eval "$target_lua" >/dev/null
      '';
    in {
      inherit key scriptName package;
    }
  ) settings;
in
{
  assertions = lib.concatLists (lib.imap0 (
    index: entry:
    let
      prefix = "hyprland.keybinds.useToggleMonitorSetup: settings[${toString index}]";
      hasSetups =
        entry ? defaultSetup
        && entry ? toggleSetup
        && lib.isAttrs entry.defaultSetup
        && lib.isAttrs entry.toggleSetup;
    in
    [
      {
        assertion = hasSetups;
        message = "${prefix}.defaultSetup and toggleSetup must be hl.monitor spec attrsets.";
      }
      {
        # The script tells the two setups apart by refresh rate only.
        assertion =
          !hasSetups
          || (
            refreshOf entry.defaultSetup != null
            && refreshOf entry.toggleSetup != null
            && refreshOf entry.defaultSetup != refreshOf entry.toggleSetup
          );
        message = "${prefix}: both setups need a mode with an explicit refresh rate (for example \"1920x1080@60\"), and the two rates must differ.";
      }
    ]
  ) settings);

  home-manager.users.${username} = {
    home.packages = map (toggle: toggle.package) toggles;

    wayland.windowManager.hyprland.settings.bind = map (
      toggle: hyprLua.execBind toggle.key "${toggle.package}/bin/${toggle.scriptName}"
    ) toggles;
  };
}
