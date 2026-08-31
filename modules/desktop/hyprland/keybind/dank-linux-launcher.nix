{
  key ? "SUPER, D",
  package ? null,
}:
{
  dank-material-shell,
  hyprLua,
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
in
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings.bind = [
    (hyprLua.execBind key "${lib.getExe dmsPackage} ipc call spotlight toggle")
  ];
}
