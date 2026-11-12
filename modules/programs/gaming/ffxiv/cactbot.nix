{ }:
{ pkgs, lib, ... }:
let
  mkChromiumWebapp = import ./chromium-webapp.nix { inherit pkgs lib; };

  cactbotRaidboss = mkChromiumWebapp rec {
    name = "cactbot-raidboss";
    desktopName = "Cactbot - Raidboss";
    class = "cactbot-raidboss-overlay";
    url = "http://proxy.iinact.com/overlay/cactbot/ui/raidboss/raidboss.html?OVERLAY_WS=ws://127.0.0.1:10501/ws";
    profileDir = "cactbot/${name}";
    extraChromiumArgs = [ "--autoplay-policy=no-user-gesture-required" ];
  };

  cactbotConfiguration = mkChromiumWebapp rec {
    name = "cactbot-configuration";
    desktopName = "Cactbot - Configuration";
    class = "cactbot-configuration-overlay";
    url = "http://proxy.iinact.com/overlay/cactbot/ui/config/config.html?OVERLAY_WS=ws://127.0.0.1:10501/ws";
    profileDir = "cactbot/${name}";
  };
in
{
  environment.systemPackages = [
    cactbotRaidboss
    cactbotConfiguration
  ];
}
