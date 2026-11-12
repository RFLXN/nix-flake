{ enableZshAlias ? false }:
{ lib, pkgs, username, ... }:
let
  package = pkgs.jetbrains.webstorm;
in
lib.mkMerge [
  {
    environment.systemPackages = [ package ];
  }
  (lib.mkIf enableZshAlias {
    home-manager.users.${username}.programs.zsh.initContent = ''
      webstorm() {
        (nohup ${lib.getExe package} "$@" >/dev/null 2>&1 &)
      }
    '';
  })
]
