{
  key ? "SUPER, D",
  package ? null,
}:
{
  config,
  hyprLua,
  lib,
  username,
  ...
}:
let
  # Default to the package the running shell uses (including any patches made
  # by useDankLinux) instead of a second, unpatched build.
  dmsPackage =
    if package != null then
      package
    else
      config.home-manager.users.${username}.programs.dank-material-shell.package;
in
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings.bind = [
    (hyprLua.execBind key "${lib.getExe dmsPackage} ipc call spotlight toggle")
  ];
}
