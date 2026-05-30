{ useQtTheme ? false, enableGtkFallback ? true }:
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
      lib.optionals (!config.programs.hyprland.enable) (
        [ hyprlandPortal ]
        ++ lib.optionals enableGtkFallback [ pkgs.xdg-desktop-portal-gtk ]
      )
      ++ lib.optionals useQtTheme [ pkgs.kdePackages.xdg-desktop-portal-kde ];

    config.hyprland = {
      default = [ "hyprland" ] ++ lib.optionals enableGtkFallback [ "gtk" ];
    } // lib.optionalAttrs useQtTheme {
      "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
    };
  };
}
