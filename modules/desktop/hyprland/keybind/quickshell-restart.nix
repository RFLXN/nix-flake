{ key ? "SUPER, backslash" }:
{ hyprLua, username, ... }:
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings.bind = [
    (hyprLua.execBind key "systemctl --user restart rflxn-shell.service")
  ];
}
