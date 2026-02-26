{ enableZshAlias ? false }:
{ lib, pkgs, username, ... }: lib.mkMerge [
  {
    environment.systemPackages = [ pkgs.jetbrains.idea ];
  }
  (lib.mkIf enableZshAlias {
    home-manager.users.${username}.programs.zsh.initContent = ''
      idea() {
        (nohup /run/current-system/sw/bin/idea "$@" >/dev/null 2>&1 &)
      }
    '';
  })
]
