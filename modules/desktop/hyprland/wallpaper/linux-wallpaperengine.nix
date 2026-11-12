{ wallpapers, fps ? 60 }:
{ hyprLua, pkgs, lib, username, ... }:
let
  wallpaperArgs = lib.concatMapStringsSep " " (
    w: "--screen-root ${lib.escapeShellArg w.screen} --bg ${lib.escapeShellArg w.wallpaper}"
  ) wallpapers;
  wallpaperCommand = "${pkgs.coreutils}/bin/env SDL_AUDIODRIVER=dummy SDL_AUDIO_DRIVER=dummy ${pkgs.linux-wallpaperengine}/bin/linux-wallpaperengine --fps ${toString fps} --silent ${wallpaperArgs}";

  restart-wallpaper = pkgs.writeShellScriptBin "restart-wallpaper" ''
    # The kernel truncates process names to 15 characters, so -x has to match
    # the truncated name; the full name never matches.
    ${pkgs.procps}/bin/pkill -x linux-wallpaper >/dev/null 2>&1 || true
    ${wallpaperCommand} &
  '';
  restart-wallpaper-desktop = pkgs.makeDesktopItem {
    name = "restart-wallpaper";
    desktopName = "Restart Wallpaper";
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

    wayland.windowManager.hyprland.settings.on = [ (hyprLua.onStart [ wallpaperCommand ]) ];
  };
}
