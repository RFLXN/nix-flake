{ }:
{ pkgs, lib, ... }:
let
  chromiumArgs = [
    "--class=mopimopi-overlay"
    "--app=http://proxy.iinact.com/overlay/mopimopi/?HOST_PORT=ws://127.0.0.1:10501"
  ];

  mopimopiScript = pkgs.writeShellScriptBin "mopimopi" ''
    profile_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/mopimopi/chromium"
    mkdir -p "$profile_dir"

    exec ${pkgs.chromium}/bin/chromium \
      --user-data-dir="$profile_dir" \
      ${lib.escapeShellArgs chromiumArgs}
  '';

  mopimopiDesktop = pkgs.makeDesktopItem {
    name = "mopimopi";
    desktopName = "MopiMopi";
    exec = "${mopimopiScript}/bin/mopimopi";
    icon = "chromium";
    terminal = false;
    type = "Application";
    categories = [ "Game" "Utility" ];
    startupWMClass = "mopimopi-overlay";
  };

  mopimopi = pkgs.symlinkJoin {
    name = "mopimopi";
    paths = [ mopimopiScript mopimopiDesktop ];
  };
in
{
  environment.systemPackages = [ mopimopi ];
}
