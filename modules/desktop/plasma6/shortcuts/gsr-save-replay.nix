{ key }:
{ username, ... }: {
  home-manager.users.${username}.programs.plasma.shortcuts = {
    "services/gsr-save-replay.desktop"._launch = key;
  };
}
