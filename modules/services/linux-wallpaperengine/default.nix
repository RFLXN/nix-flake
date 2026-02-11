# This service requires Wallpaper Engine Installation from Steam
{ wallpapers, fps ? 60 }:
{ pkgs, lib, username, ... }:
let
  wallpaperArgs = lib.concatMapStringsSep " " (w: "--screen-root ${w.screen} --bg ${w.wallpaper}") wallpapers;

  restart-wallpaper = pkgs.writeShellScriptBin "restart-wallpaper" ''
    systemctl --user restart linux-wallpaperengine
  '';

  restart-wallpaper-desktop = pkgs.makeDesktopItem {
    name = "restart-wallpaper";
    desktopName = "Restart Wallpaper Engine";
    exec = "${restart-wallpaper}/bin/restart-wallpaper";
    icon = "preferences-desktop-wallpaper";
    terminal = false;
    type = "Application";
    categories = [ "Utility" ];
  };
in {
  home-manager.users.${username} = {
    home.packages = [ restart-wallpaper restart-wallpaper-desktop ];

    systemd.user.services.linux-wallpaperengine = {
      Unit = {
        Description = "Linux Wallpaper Engine";
        After = [ "graphical-session.target" "plasma-plasmashell.service" ];
        BindsTo = [ "plasma-plasmashell.service" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.linux-wallpaperengine}/bin/linux-wallpaperengine --fps ${toString fps} --silent ${wallpaperArgs}";
        Restart = "on-failure";
        RestartSec = 3;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
