{ key ? "ALT, F9" }:
{ hyprLua, username, ... }:
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings.bind = [
    (hyprLua.execBind key "gsr-save-replay")
  ];
}
