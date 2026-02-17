{ enableKdeSupport ? false, enableHyprlandSupport ? false, enableGtkSupport ? enableHyprlandSupport }:
{ pkgs, lib, ... }: {
  xdg.portal = {
    enable = true;
    extraPortals =
      lib.optionals enableKdeSupport [ pkgs.kdePackages.xdg-desktop-portal-kde ]
      ++ lib.optionals enableHyprlandSupport [ pkgs.xdg-desktop-portal-hyprland ]
      ++ lib.optionals enableGtkSupport [ pkgs.xdg-desktop-portal-gtk ];
  };
}
