{ isWayland ? false }:
{ pkgs, ... }: {
  environment.systemPackages = [
    (if isWayland then pkgs.wineWow64Packages.waylandFull else pkgs.wineWowPackages.full)
  ];
}
