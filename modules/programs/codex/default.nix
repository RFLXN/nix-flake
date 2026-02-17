{  }:
{ pkgs, ... }:
let
  codexPackage = pkgs.callPackage ./pkg.nix { };
in {
  environment.systemPackages = [
    codexPackage
  ];
}
