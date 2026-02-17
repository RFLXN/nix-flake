{ workspace }:
{ lib, username, ... }: {
  home-manager.users.${username} = {
    wayland.windowManager.hyprland.settings.windowrule = [
      "workspace ${workspace}, class:^(vesktop)$"
      "tile, class:^(vesktop)$"
    ];
  };
}
