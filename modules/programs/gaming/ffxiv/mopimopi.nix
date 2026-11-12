{ }:
{ pkgs, lib, ... }:
let
  mkChromiumWebapp = import ./chromium-webapp.nix { inherit pkgs lib; };

  mopimopi = mkChromiumWebapp {
    name = "mopimopi";
    desktopName = "MopiMopi";
    class = "mopimopi-overlay";
    url = "http://proxy.iinact.com/overlay/mopimopi/?HOST_PORT=ws://127.0.0.1:10501";
    profileDir = "mopimopi/chromium";
  };
in
{
  environment.systemPackages = [ mopimopi ];
}
