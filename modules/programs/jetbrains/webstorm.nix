{ enableZshAlias ? false }:
{ lib, pkgs, username, ... }: lib.mkMerge [
  {
    environment.systemPackages = [ pkgs.jetbrains.webstorm ];
  }
  (lib.mkIf enableZshAlias {
    home-manager.users.${username}.programs.zsh.initContent = ''
      webstorm() {
        (nohup /run/current-system/sw/bin/webstorm "$@" >/dev/null 2>&1 &)
      }
    '';
  })
]
