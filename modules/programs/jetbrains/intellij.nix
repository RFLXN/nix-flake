{ enableZshAlias ? false }:
{ lib, pkgs, username, ... }:
let
  package = pkgs.jetbrains.idea;
in
lib.mkMerge [
  {
    environment.systemPackages = [ package ];
  }
  (lib.mkIf enableZshAlias {
    home-manager.users.${username}.programs.zsh.initContent = ''
      idea() {
        (nohup ${lib.getExe package} "$@" >/dev/null 2>&1 &)
      }
    '';
  })
]
