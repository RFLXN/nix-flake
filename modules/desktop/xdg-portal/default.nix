{ enableKdeSupport ? false, enableHyprlandSupport ? false, enableGtkSupport ? enableHyprlandSupport }:
{ config, pkgs, lib, ... }:
let
  hyprlandPortal =
    if config.programs.hyprland.enable
    then config.programs.hyprland.portalPackage
    else pkgs.xdg-desktop-portal-hyprland;
in {
  xdg.portal = {
    enable = true;
    extraPortals =
      lib.optionals enableKdeSupport [ pkgs.kdePackages.xdg-desktop-portal-kde ]
      ++ lib.optionals enableHyprlandSupport [ hyprlandPortal ]
      ++ lib.optionals enableGtkSupport [ pkgs.xdg-desktop-portal-gtk ];
  };
}
