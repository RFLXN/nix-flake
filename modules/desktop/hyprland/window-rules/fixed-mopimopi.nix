{ workspace }:
{ username, ... }: {
  home-manager.users.${username} = {
    wayland.windowManager.hyprland.settings.windowrule = [
      "match:class ^(chrome-proxy\\.iinact\\.com__overlay_mopimopi_-Default)$, workspace ${workspace}"
    ];
  };
}
