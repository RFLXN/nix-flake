{ isWayland ? false }:
{ pkgs, ... }: {
  environment.systemPackages = [
    (if isWayland then pkgs.wineWowPackages.waylandFull else pkgs.wineWowPackages.full)
  ];
}
