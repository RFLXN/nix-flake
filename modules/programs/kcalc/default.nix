{ enableWindowsAlias ? false }:
{ lib, pkgs, ... }: lib.mkMerge [
  {
    environment.systemPackages = [ pkgs.kdePackages.kcalc ];
  }
  (lib.mkIf enableWindowsAlias {
    environment.systemPackages = [
      (pkgs.makeDesktopItem {
        name = "calc";
        desktopName = "calc";
        exec = "${pkgs.kdePackages.kcalc}/bin/kcalc";
        icon = "kcalc";
        categories = [ "Utility" "Calculator" ];
      })
    ];
  })
]
