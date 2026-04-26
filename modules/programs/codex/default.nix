{ }:
{ pkgs, codex-cli-nix, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
in {
  environment.systemPackages = [
    codex-cli-nix.packages.${system}.default
  ];
}
