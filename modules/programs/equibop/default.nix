{ package ? null }:
{ pkgs, username, ... }:
let
  equibopPackage = if package != null then package else pkgs.equibop;
  desktopId = "equibop.desktop";
  discordScheme = "x-scheme-handler/discord";
in
{
  environment.systemPackages = [ equibopPackage ];

  home-manager.users.${username}.xdg.mimeApps = {
    enable = true;
    defaultApplications.${discordScheme} = [ desktopId ];
    associations.added.${discordScheme} = [ desktopId ];
  };
}
