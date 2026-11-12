{ isWayland ? false }:
{ pkgs, ... }: {
  environment.systemPackages = [
    (if isWayland then pkgs.wineWow64Packages.waylandFull else pkgs.wineWow64Packages.full)
  ];
}
