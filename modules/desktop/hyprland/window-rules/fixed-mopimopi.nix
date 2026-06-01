{ workspace }:
{ username, ... }: {
  home-manager.users.${username} = {
    wayland.windowManager.hyprland.settings.window_rule = [
      {
        match.class = "^(chrome-proxy\\.iinact\\.com__overlay_mopimopi_-Default)$";
        workspace = workspace;
      }
    ];
  };
}
