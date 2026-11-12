{ key ? "SUPER SHIFT, O", delaySeconds ? 1 }:
{ config, hyprLua, username, pkgs, ... }:
let
  screenOff = pkgs.writeShellScriptBin "hypr-screen-off" ''
    ${pkgs.coreutils}/bin/sleep ${toString delaySeconds}
    ${config.programs.hyprland.package}/bin/hyprctl dispatch 'hl.dsp.dpms({ action = "toggle" })'
  '';
in
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings.bind = [
    (hyprLua.execBind key "${screenOff}/bin/hypr-screen-off")
  ];
}
