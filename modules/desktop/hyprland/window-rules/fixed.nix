# Pins windows whose class matches the given regex to a workspace.
{ class, workspace }:
{ username, ... }:
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings.window_rule = [
    {
      match.class = class;
      inherit workspace;
    }
  ];
}
