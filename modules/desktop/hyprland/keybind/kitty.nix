{ key ? "SUPER, R" }:
{ username, ... }:
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings.bind = [
    "${key}, exec, kitty"
  ];
}