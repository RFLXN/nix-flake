# Chromium "--app" launcher with its own profile directory and desktop entry.
# profileDir is relative to $XDG_STATE_HOME.
{ pkgs, lib }:
{
  name,
  desktopName,
  class,
  url,
  profileDir,
  extraChromiumArgs ? [ ],
}:
let
  chromiumArgs = [ "--class=${class}" ] ++ extraChromiumArgs ++ [ "--app=${url}" ];

  script = pkgs.writeShellScriptBin name ''
    profile_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/${profileDir}"
    mkdir -p "$profile_dir"

    exec ${pkgs.chromium}/bin/chromium \
      --user-data-dir="$profile_dir" \
      ${lib.escapeShellArgs chromiumArgs}
  '';

  desktop = pkgs.makeDesktopItem {
    inherit name desktopName;
    exec = "${script}/bin/${name}";
    icon = "chromium";
    terminal = false;
    type = "Application";
    categories = [
      "Game"
      "Utility"
    ];
    startupWMClass = class;
  };
in
pkgs.symlinkJoin {
  inherit name;
  paths = [
    script
    desktop
  ];
}
