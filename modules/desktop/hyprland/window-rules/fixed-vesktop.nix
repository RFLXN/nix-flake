{ workspace }:
{ lib, username, ... }: {
  home-manager.users.${username} = {
    wayland.windowManager.hyprland.settings.windowrule = [
      "match:class ^(vesktop)$, workspace ${workspace}, tile 1"
    ];
  };
}
