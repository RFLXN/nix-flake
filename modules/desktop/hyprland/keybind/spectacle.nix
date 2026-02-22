{ key ? ", Print" }:
{ username, pkgs, ... }:
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings.bind = [
    "${key}, exec, ${pkgs.kdePackages.spectacle}/bin/spectacle"
  ];
}
