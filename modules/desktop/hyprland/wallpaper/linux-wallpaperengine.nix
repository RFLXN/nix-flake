{ wallpapers, fps ? 60 }:
{ pkgs, lib, username, ... }:
let
  wallpaperArgs = lib.concatMapStringsSep " " (w: "--screen-root ${w.screen} --bg ${w.wallpaper}") wallpapers;
  wallpaperCommand = "${pkgs.linux-wallpaperengine}/bin/linux-wallpaperengine --fps ${toString fps} --silent ${wallpaperArgs}";

  restart-wallpaper = pkgs.writeShellScriptBin "restart-wallpaper" ''
    pkill -x linux-wallpaperengine >/dev/null 2>&1 || true
    nohup ${wallpaperCommand} >/dev/null 2>&1 &
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
in
{
  assertions = [
    {
      assertion = wallpapers != [];
      message = "hyprland.wallpaper.useLinuxWallpaperEngine: wallpapers must not be empty.";
    }
  ];

  home-manager.users.${username} = {
    home.packages = [ restart-wallpaper restart-wallpaper-desktop ];

    wayland.windowManager.hyprland.settings.exec-once = [
      wallpaperCommand
    ];
  };
}
