{ }:
{ pkgs, ... }:
let
  mopimopiScript = pkgs.writeShellScriptBin "mopimopi" ''
    exec ${pkgs.chromium}/bin/chromium \
      --class=mopimopi-overlay \
      --app="http://proxy.iinact.com/overlay/mopimopi/?HOST_PORT=ws://127.0.0.1:10501"
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
