{ key ? "ALT, F9" }:
{ username, ... }:
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings.bind = [
    "${key}, exec, gsr-save-replay"
  ];
}