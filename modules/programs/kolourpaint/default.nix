{ enableWindowsAlias ? false }:
{ lib, pkgs, ... }: lib.mkMerge [
  {
    environment.systemPackages = [ pkgs.kdePackages.kolourpaint ];
  }
  (lib.mkIf enableWindowsAlias {
    environment.systemPackages = [
      (pkgs.makeDesktopItem {
        name = "pbrush";
        desktopName = "pbrush";
        exec = "${pkgs.kdePackages.kolourpaint}/bin/kolourpaint";
        icon = "kolourpaint";
        categories = [ "Graphics" "RasterGraphics" ];
      })
    ];
  })
]
