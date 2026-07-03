{ key ? "SUPER, backslash" }:
{ username, ... }:
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings.bind = [
    "${key}, exec, systemctl --user restart rflxn-shell.service"
  ];
}
