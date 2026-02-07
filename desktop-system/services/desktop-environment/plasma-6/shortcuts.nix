{ username, ... }: {
  home-manager.users.${username} = {
    programs.plasma = {
      shortcuts = {
        "services/kitty.desktop"._launch = "Meta+R";
        "services/gsr-save-replay.desktop"._launch = "Alt+F9";
        "services/restart-wallpaper.desktop"._launch = "Meta+\\";
      };
    };
  };
}