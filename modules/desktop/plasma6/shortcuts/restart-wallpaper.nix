{ key }:
{ username, ... }: {
  home-manager.users.${username}.programs.plasma.shortcuts = {
    "services/restart-wallpaper.desktop"._launch = key;
  };
}
