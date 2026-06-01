{ key ? "SUPER SHIFT, O", delaySeconds ? 1 }:
{ hyprLua, username, pkgs, ... }:
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings.bind = [
    (hyprLua.execBind key "${pkgs.bash}/bin/sh -c '${pkgs.coreutils}/bin/sleep ${toString delaySeconds}; ${pkgs.hyprland}/bin/hyprctl dispatch \"hl.dsp.dpms({ action = \\\"toggle\\\" })\"'")
  ];
}
