{ }:
{ pkgs, ... }: {
  services.blueman.enable = true;
  # Only enable D-Bus service, don't autostart tray applet
  environment.etc."xdg/autostart/blueman.desktop".text = "";
}
