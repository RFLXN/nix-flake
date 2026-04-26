{
  enableSessionWide ? false,
  settings ? {},
  settingsPerApplication ? {},
}:
{ pkgs, username, ... }:
{
  programs.steam.extraPackages = [ pkgs.mangohud ];

  home-manager.users.${username}.programs.mangohud = {
    enable = true;
    inherit enableSessionWide settings settingsPerApplication;
  };
}
