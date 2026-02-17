{ qtUseGtkPlatformTheme ? true }:
{ lib, username, ... }: {
  programs.dconf.enable = true;

  environment.sessionVariables = lib.optionalAttrs qtUseGtkPlatformTheme {
    QT_QPA_PLATFORMTHEME = "gtk3";
  };

  home-manager.users.${username}.dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
