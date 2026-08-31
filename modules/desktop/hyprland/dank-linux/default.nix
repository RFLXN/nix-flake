{
  package ? null,
  settings ? { },
  systemdTarget ? null,
  theme ? null,
}:
{
  dank-material-shell,
  lib,
  pkgs,
  username,
  ...
}:
let
  dmsPackage =
    if package != null then
      package
    else
      dank-material-shell.packages.${pkgs.stdenv.hostPlatform.system}.default;

  themeId =
    if theme == null then
      null
    else
      theme.id or (throw "hyprland.useDankLinux: theme.id is required when theme is set");

  themeConfigPath = "DankMaterialShell/themes/${themeId}/theme.json";
in
{
  home-manager.users.${username} = {
    imports = [ dank-material-shell.homeModules.dank-material-shell ];

    programs.dank-material-shell = {
      enable = true;
      package = dmsPackage;
      settings = settings // lib.optionalAttrs (theme != null) {
        currentThemeName = "custom";
        customThemeFile = "/home/${username}/.config/${themeConfigPath}";
      };
      systemd = {
        enable = true;
      }
      // lib.optionalAttrs (systemdTarget != null) {
        target = systemdTarget;
      };
    };

    xdg.configFile =
      lib.optionalAttrs (settings != { }) {
        "DankMaterialShell/settings.json".force = true;
      }
      // lib.optionalAttrs (theme != null) {
        ${themeConfigPath} = {
          force = true;
          text = builtins.toJSON theme;
        };
      };

    systemd.user.services.dms.Service.Environment = [ "DMS_DISABLE_POLKIT=1" ];
  };
}
