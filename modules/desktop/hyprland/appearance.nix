{
  gapSize ? 5,
  borderSize ? 2,
  rounding ? 5,
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
{ username, ... }: {
  home-manager.users.${username}.wayland.windowManager.hyprland.settings = {
    config = {
      general = {
        gaps_in = gapSize;
        gaps_out = gapSize * 2;
        border_size = borderSize;
        col = {
          active_border = activeBorderColor;
          inactive_border = inactiveBorderColor;
        };
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
      };

      scrolling = {
        fullscreen_on_one_column = false;
        column_width = 0.45;
      };
    };

    curve = [
      {
        _args = [
          "myBezier"
          {
            type = "bezier";
            points = [
              [ 0.05 0.9 ]
              [ 0.1 1.05 ]
            ];
          }
        ];
      }
    ];

    animation = [
      { leaf = "windows"; enabled = true; speed = 7; bezier = "myBezier"; }
      { leaf = "windowsOut"; enabled = true; speed = 7; bezier = "default"; style = "popin 80%"; }
      { leaf = "border"; enabled = true; speed = 10; bezier = "default"; }
      { leaf = "fade"; enabled = true; speed = 7; bezier = "default"; }
      { leaf = "workspaces"; enabled = true; speed = 6; bezier = "default"; }
    ];
  };
}
