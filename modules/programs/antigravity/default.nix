{ }:
{ pkgs, antigravity-nix, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
in {
  environment.systemPackages = [
    antigravity-nix.packages.${system}.default
    antigravity-nix.packages.${system}.google-antigravity-ide
    antigravity-nix.packages.${system}.google-antigravity-cli
  ];
}
