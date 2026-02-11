{ }:
{ pkgs, pkgs-unstable, ... }:
let
  vesktop-ime = pkgs-unstable.vesktop.overrideAttrs (old: {
    desktopItems = [
      (pkgs.makeDesktopItem {
        name = "vesktop";
        desktopName = "Vesktop";
        exec = "vesktop --enable-wayland-ime --ozone-platform=wayland --enable-features=UseOzonePlatform,WaylandWindowDecorations %U";
        icon = "vesktop";
        startupWMClass = "Vesktop";
        genericName = "Internet Messenger";
        keywords = [ "discord" "vencord" "electron" "chat" ];
        categories = [ "Network" "InstantMessaging" "Chat" ];
      })
    ];
  });
in {
  environment.systemPackages = [ vesktop-ime ];
}
