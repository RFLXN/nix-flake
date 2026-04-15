{ }:
{ pkgs, codex-desktop, ... }:
{
  environment.systemPackages = [
    (pkgs.callPackage "${codex-desktop}/pkg.nix" {})
  ];
}
