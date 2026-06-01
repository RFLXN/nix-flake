{
  enableXWayland ? true,
  monitors ? null,
  workspaces ? null,
  followMouse ? 1,
  pointerSpeed ? 0,
  enableMouseAcceleration ? false,
  disableHardwareCursors ? false,
  noCursorWarps ? true
}:
{ pkgs, lib, username, ... }@args:
let
  hyprLua = import ./lua-helpers.nix { inherit lib; };
  system = pkgs.stdenv.hostPlatform.system;
  hyprlandInput = args.hyprland or null;
  useHyprlandGit = hyprlandInput != null;
  hyprlandPackages = if useHyprlandGit then hyprlandInput.packages.${system} else null;
in {
  _module.args.hyprLua = hyprLua;

  assertions = [
    {
      assertion = monitors == null || lib.all lib.isAttrs monitors;
      message = "hyprland.useHyprland: monitors must be a list of hl.monitor spec attrsets.";
    }
    {
      assertion = workspaces == null || lib.all lib.isAttrs workspaces;
      message = "hyprland.useHyprland: workspaces must be a list of hl.workspace_rule spec attrsets.";
    }
  ];

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
    SDL_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
  };

  environment.variables.XMODIFIERS = "@im=fcitx";

  services.xserver.enable = enableXWayland;

  home-manager.users.${username}.wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.enable = false;
    configType = "lua";
    xwayland.enable = enableXWayland;

    settings = {
      on = [ (hyprLua.onStart [ "fcitx5 -d" ]) ];

      monitor =
        if monitors != null
        then monitors
        else [
          {
            output = "";
            mode = "preferred";
            position = "auto";
            scale = 1;
          }
        ];

      workspace_rule = if workspaces != null then workspaces else [];

      config = {
        input = {
          kb_layout = "us";
          follow_mouse = followMouse;
          sensitivity = pointerSpeed;
          accel_profile = if enableMouseAcceleration then "adaptive" else "flat";
        };

        general.resize_on_border = true;

        cursor = {
          no_warps = noCursorWarps;
        } // lib.optionalAttrs disableHardwareCursors {
          no_hardware_cursors = true;
        };

        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
          key_press_enables_dpms = true;
        };
      };
    };
  };
}
