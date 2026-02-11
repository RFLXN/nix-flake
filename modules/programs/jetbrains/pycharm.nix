{ enableZshAlias ? false }:
{ lib, pkgs-unstable, username, ... }: lib.mkMerge [
  {
    environment.systemPackages = [ pkgs-unstable.jetbrains.pycharm-professional ];
  }
  (lib.mkIf enableZshAlias {
    home-manager.users.${username}.programs.zsh.initContent = ''
      pycharm() {
        (nohup /run/current-system/sw/bin/pycharm-professional "$@" >/dev/null 2>&1 &)
      }
    '';
  })
]
