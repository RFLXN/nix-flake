{ key }:
{ username, ... }: {
  home-manager.users.${username}.programs.plasma.shortcuts = {
    "services/kitty.desktop"._launch = key;
  };
}
