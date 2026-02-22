{ theme ? "Papirus-Dark" }:
{ pkgs, username, ... }:
{
  assertions = [
    {
      assertion = builtins.elem theme [ "Papirus" "Papirus-Dark" "Papirus-Light" ];
      message = "gtk.theme.usePapirusIcon: theme must be one of \"Papirus\", \"Papirus-Dark\", or \"Papirus-Light\".";
    }
  ];

  home-manager.users.${username}.gtk = {
    enable = true;
    iconTheme = {
      name = theme;
      package = pkgs.papirus-icon-theme;
    };
  };
}
