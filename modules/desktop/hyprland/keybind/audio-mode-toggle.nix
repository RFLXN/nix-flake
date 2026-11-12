{ key ? "SUPER, A" }:
{ hyprLua, username, ... }:
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings.bind = [
    (hyprLua.execBind key "audio-mode toggle")
  ];
}
