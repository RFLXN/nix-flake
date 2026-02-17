{ key ? "SUPER, D" }:
{ username, ... }:
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings.bind = [
    "${key}, exec, rofi -show drun"
  ];
}