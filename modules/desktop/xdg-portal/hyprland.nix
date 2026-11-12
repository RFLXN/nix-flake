{ useQtTheme ? false, enableGtkFallback ? true }:
{ config, pkgs, lib, ... }: {
  xdg.portal = {
    enable = true;
    # programs.hyprland already installs its own portal and the GTK portal.
    extraPortals =
      lib.optionals (!config.programs.hyprland.enable) (
        [ pkgs.xdg-desktop-portal-hyprland ]
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
