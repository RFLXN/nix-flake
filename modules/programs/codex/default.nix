{ }:
{ pkgs, codex-cli-nix, ... }: {
  environment.systemPackages = [
    codex-cli-nix.packages.${pkgs.system}.default
  ];
}
