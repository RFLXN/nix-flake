{ key ? "Print" }:
{ hyprLua, username, pkgs, ... }:
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings.bind = [
    (hyprLua.execBind ", ${key}" "${pkgs.hyprshot}/bin/hyprshot -m region --clipboard-only")
    (hyprLua.execBind "ALT, ${key}" "${pkgs.hyprshot}/bin/hyprshot -m window -m active --clipboard-only")
  ];
}
