{  }:
{ pkgs, username, ... }:
{
  home-manager.users.${username} = {
    wayland.windowManager.hyprland = {
      plugins = [ pkgs.hyprlandPlugins.hyprbars ];
      settings = {
        plugins.hyprbars = {
          bar_height = 15;
          bar_title_enabled = true;
        };
      };
    };
  };
}