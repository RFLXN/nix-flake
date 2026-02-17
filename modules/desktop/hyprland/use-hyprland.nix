{
  enableXWayland ? true,
  monitors ? null,
  workspaces ? null,
  followMouse ? 1,
  pointerSpeed ? 0,
  enableMouseAcceleration ? false
}:
{ pkgs, lib, username, ... }: {
  programs.uwsm.enable = true;
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = enableXWayland;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    GDK_BACKEND = "wayland,x11";
    MOZ_ENABLE_WAYLAND = "1";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };

  home-manager.users.${username}.wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    xwayland.enable = enableXWayland;

    settings = {
      exec-once = [ "fcitx5 -d" ];

      monitor = if monitors != null then monitors else [ ",preferred,auto,1" ];

      workspace = if workspaces != null then workspaces else [];

      input = {
        kb_layout = "us";
        follow_mouse = followMouse;
        sensitivity = pointerSpeed;
        accel_profile = if enableMouseAcceleration then "adaptive" else "flat";
      };

      general.resize_on_border = true;

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };
    };
  };
}
