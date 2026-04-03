{ key ? "SUPER SHIFT, O", delaySeconds ? 1 }:
{ username, pkgs, ... }:
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings.bind = [
    "${key}, exec, ${pkgs.bash}/bin/sh -c '${pkgs.coreutils}/bin/sleep ${toString delaySeconds}; ${pkgs.hyprland}/bin/hyprctl dispatch dpms toggle'"
  ];
}
