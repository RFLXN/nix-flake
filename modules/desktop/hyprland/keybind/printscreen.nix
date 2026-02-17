{ key ? ", Print" }:
{ username, pkgs, ... }:
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings.bind = [
    "${key}, exec, ${pkgs.grimblast}/bin/grimblast copy area"
  ];
}
