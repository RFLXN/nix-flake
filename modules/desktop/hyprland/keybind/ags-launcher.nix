{ key ? "SUPER, D" }:
{ hyprLua, username, ... }:
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings.bind = [
    (hyprLua.execBind key "ags request launcher toggle")
  ];
}
