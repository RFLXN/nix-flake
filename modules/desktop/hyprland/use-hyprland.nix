{
  enableXWayland ? true,
  monitors ? null,
  workspaces ? null,
  followMouse ? 1,
  pointerSpeed ? 0,
  enableMouseAcceleration ? false,
  disableHardwareCursors ? false
}:
{ pkgs, lib, username, hyprland ? null, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  useHyprlandGit = hyprland != null;
  hyprlandPackages = if useHyprlandGit then hyprland.packages.${system} else null;
in {
  programs.uwsm.enable = true;
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = enableXWayland;
  } // lib.optionalAttrs useHyprlandGit {
    package = hyprlandPackages.hyprland;
    portalPackage = hyprlandPackages.xdg-desktop-portal-hyprland;
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

  services.xserver.enable = enableXWayland;

  home-manager.users.${username}.wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
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
    } // lib.optionalAttrs disableHardwareCursors {
      cursor = {
        no_hardware_cursors = true;
      };
    };
  };
}
