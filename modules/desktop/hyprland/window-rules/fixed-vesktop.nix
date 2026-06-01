{ workspace }:
{ lib, username, ... }: {
  home-manager.users.${username} = {
    wayland.windowManager.hyprland.settings.window_rule = [
      {
        match.class = "^(vesktop)$";
        workspace = workspace;
      }
    ];
  };
}
