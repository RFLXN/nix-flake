{ }:
{ pkgs, quickshell, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  quickshellPackage = quickshell.packages.${system}.default.withModules [
    pkgs.qt6Packages.qtsvg
    pkgs.qt6Packages.qtimageformats
    pkgs.qt6Packages.qtmultimedia
    pkgs.qt6Packages.qt5compat
  ];
in {
  environment.systemPackages = [ quickshellPackage ];
}
