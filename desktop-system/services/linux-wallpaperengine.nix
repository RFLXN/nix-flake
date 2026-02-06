# This service requires Wallpaper Engine Installation from Steam
{ pkgs, username, ... }: let
  main-screen = "DP-3";
  main-bg = "3455304967";

  sub-screen = "HDMI-A-1";
  sub-bg = "2897249674";
in {
  home-manager.users.${username} = {
    systemd.user.services.linux-wallpaperengine = {
      Unit = {
        Description = "Linux Wallpaper Engine";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.linux-wallpaperengine}/bin/linux-wallpaperengine --fps 60 --silent --screen-root ${main-screen} --bg ${main-bg} --screen-root ${sub-screen} --bg ${sub-bg}";
        Restart = "on-failure";
        RestartSec = 3;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
