{ workspace }:
{ lib, username, ... }: {
  home-manager.users.${username} = {
    wayland.windowManager.hyprland.settings.windowrule = [
      "workspace ${workspace}, class:^(spotify)$"
      "tile, class:^(spotify)$"
    ];
  };
}
