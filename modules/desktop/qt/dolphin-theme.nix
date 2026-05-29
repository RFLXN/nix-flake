{ colorScheme ? "*" }:
{ username, ... }: {
  home-manager.users.${username}.qt.kde.settings.dolphinrc.UiSettings.ColorScheme = colorScheme;
}
