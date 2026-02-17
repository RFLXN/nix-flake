{ key ? "SUPER, backslash" }:
{ username, ... }:
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings.bind = [
    "${key}, exec, ags quit; ags run"
  ];
}
