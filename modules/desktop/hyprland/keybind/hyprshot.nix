{ key ? "Print" }:
{ username, pkgs, ... }:
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings.bind = [
    ", ${key}, exec, ${pkgs.hyprshot}/bin/hyprshot -m region --clipboard-only"
    "Alt_L, ${key}, exec, ${pkgs.hyprshot}/bin/hyprshot -m window -m active --clipboard-only"
  ];
}
