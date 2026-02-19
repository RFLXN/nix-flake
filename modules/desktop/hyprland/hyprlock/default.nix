{ }:
{ lib, username, ... }:
{
  security.pam.services.hyprlock = { };

  home-manager.users.${username} = {
    programs.hyprlock = {
      enable = true;

      settings = {
        general = {
          hide_cursor = true;
          grace = 2;
        };

        animations = {
          enabled = true;
          bezier = [ "easeInOut, 0.45, 0.05, 0.55, 0.95" ];
          animation = [
            "fadeIn, 1, 4, easeInOut"
            "fadeOut, 1, 3, easeInOut"
            "inputFieldDots, 1, 2, easeInOut"
          ];
        };

        background = [
          {
            monitor = "";
            path = "screenshot";
            blur_passes = 2;
            blur_size = 10;
          }
        ];

        # background rectangle
        /* shape = [
          {
            monitor = "";
            size = "320, 55";
            color = "rgba(255, 255, 255, .2)";
            rounding = -1;
            border_size = 0;
            border_color = "rgba(255, 255, 255, 1)";
            rotate = 0;
            xray = false;
            position = "170, -140";
            halign = "left";
            valign = "center";
          }
        ]; */

        # password input
        input-field = [
          {
            monitor = "";
            size = "320, 55";
            outline_thickness = 0;
            dots_size = 0.2;
            dots_spacing = 0.2;
            dots_center = true;
            outer_color = "rgba(196, 167, 231, 0.1)";
            inner_color = "rgba(196, 167, 231, 0.2)";
            font_color = "rgb(224, 222, 244)";
            fade_on_empty = false;
            font_family = "Noto Sans";
            placeholder_text = "<i><span foreground=\"##6e6a86b3\">Password</span></i>";
            hide_input = false;
            position = "170, -220";
            halign = "left";
            valign = "center";
          }
        ];
        
        label = [
          {
            monitor = "";
            text = "Welcome!";
            color = "rgba(224, 222, 244, 0.75)";
            font_size = 55;
            font_family = "Noto Sans";
            position = "165, 320";
            halign = "left";
            valign = "center";
          }
          {
            monitor = "";
            # time
            text = "cmd[update:1000] echo \"<span>$(date +\"%I:%M\")</span>\"";
            color = "rgba(224, 222, 244, 0.75)";
            font_size = 40;
            text_align = "center";
            font_family = "Noto Sans CJK JP";
            position = "255, 240";
            halign = "left";
            valign = "center";
          }
          {
            monitor = "";
            # date
            text = "cmd[update:60000] date +\"%Y年 %m月 %d日\"";
            color = "rgba(224, 222, 244, 0.75)";
            font_size = 20;
            text_align = "center";
            font_family = "Noto Sans CJK JP";
            position = "220, 175";
            halign = "left";
            valign = "center";
          }
          {
            monitor = "";
            text = "  $USER";
            color = "rgba(224, 222, 244, 0.8)";
            font_size = 16;
            font_family = "FiraCode Nerd Font";
            position = "281, -140";
            halign = "left";
            valign = "center";
          }
        ];
      };
    };

    wayland.windowManager.hyprland.settings.exec-once = lib.mkAfter [ "sleep 1 && hyprlock" ];
  };
}
