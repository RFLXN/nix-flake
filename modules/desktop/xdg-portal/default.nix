{ enableKdeSupport ? false }:
{ pkgs, lib, ... }: {
  xdg.portal = {
    enable = true;
    extraPortals = lib.optionals enableKdeSupport [
      pkgs.kdePackages.xdg-desktop-portal-kde
    ];
  };
}
