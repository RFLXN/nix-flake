{
  gapSize ? 5,
  borderSize ? 2,
  rounding ? 10,
  activeBorderColor ? "rgb(89b4fa)",
  inactiveBorderColor ? "rgb(585b70)",
  enableAnimations ? true,
  enableBlur ? true,
  activeOpacity ? 0.94,
  inactiveOpacity ? 0.86,
  fullscreenOpacity ? 1.0,
  blurSize ? 8,
  blurPasses ? 2
}:
{ username, lib, ... }: {
  home-manager.users.${username}.wayland.windowManager.hyprland.settings = {
    general = {
      gaps_in = gapSize;
      gaps_out = gapSize * 2;
      border_size = borderSize;
      "col.active_border" = activeBorderColor;
      "col.inactive_border" = inactiveBorderColor;
      layout = "dwindle";
    };

    decoration = {
      rounding = rounding;
      active_opacity = activeOpacity;
      inactive_opacity = inactiveOpacity;
      fullscreen_opacity = fullscreenOpacity;
      blur = {
        enabled = enableBlur;
        size = blurSize;
        passes = blurPasses;
        new_optimizations = true;
      };
      shadow = {
        enabled = true;
        range = 10;
        render_power = 3;
      };
    };

    animations = {
      enabled = enableAnimations;
      bezier = [ "myBezier, 0.05, 0.9, 0.1, 1.05" ];
      animation = [
        "windows, 1, 7, myBezier"
        "windowsOut, 1, 7, default, popin 80%"
        "border, 1, 10, default"
        "fade, 1, 7, default"
        "workspaces, 1, 6, default"
      ];
    };

    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };
  };
}
