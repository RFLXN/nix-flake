{ }:
{ pkgs, username, codex-cli-nix, codex-desktop, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  home-manager.users.${username} = {
    imports = [
      codex-desktop.homeManagerModules.default
    ];

    programs.codexDesktopLinux = {
      enable = true;
      remoteControl.package = codex-cli-nix.packages.${system}.default;
    };
  };
}
