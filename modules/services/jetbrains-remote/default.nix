{ ides ? [] }:
{ pkgs, username, ... }: {
  home-manager.users.${username}.programs.jetbrains-remote = {
    enable = true;
    ides = ides;
  };
}
