{
  mountOnMedia ? false,
  notify ? true,
  tray ? "auto",
}:
{ pkgs, username, ... }:
{
  services.udisks2 = {
    enable = true;
    inherit mountOnMedia;
  };

  environment.systemPackages = [ pkgs.udiskie ];

  home-manager.users.${username}.services.udiskie = {
    enable = true;
    automount = true;
    inherit notify tray;
  };
}
