{ theme ? "Papirus-Dark" }:
{ pkgs, username, ... }:
{
  assertions = [
    {
      assertion = builtins.elem theme [ "Papirus" "Papirus-Dark" "Papirus-Light" ];
      message = "qt.theme.usePapirusIcon: theme must be one of \"Papirus\", \"Papirus-Dark\", or \"Papirus-Light\".";
    }
  ];

  environment.systemPackages = [ pkgs.papirus-icon-theme ];

  home-manager.users.${username}.qt = {
    enable = true;
    qt5ctSettings.Appearance.icon_theme = theme;
    qt6ctSettings.Appearance.icon_theme = theme;
  };
}
