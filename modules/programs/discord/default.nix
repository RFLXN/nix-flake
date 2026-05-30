{ }:
{ pkgs, ... }:
let
  discord-ime = pkgs.discord.overrideAttrs (_old: {
    desktopItem = pkgs.makeDesktopItem {
      name = "discord";
      desktopName = "Discord";
      exec = "env NIXOS_OZONE_WL= GTK_IM_MODULE=fcitx Discord --ozone-platform=x11 %U";
      icon = "discord";
      startupWMClass = "discord";
      genericName = pkgs.discord.meta.description or "Internet Messenger";
      categories = [ "Network" "InstantMessaging" ];
      mimeTypes = [ "x-scheme-handler/discord" ];
    };
  });
in
{
  environment.systemPackages = [ discord-ime ];
}
