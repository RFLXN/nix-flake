{ workspace }:
{ lib, username, ... }: {
  home-manager.users.${username} = {
    wayland.windowManager.hyprland.settings.windowrule = [
      "match:workspace ${workspace}, pseudo on, size (monitor_w) (window_h)"
    ];
  };
}
