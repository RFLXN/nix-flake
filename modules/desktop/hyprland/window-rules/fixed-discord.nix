{ workspace }:
{ username, ... }:
{
  home-manager.users.${username} = {
    wayland.windowManager.hyprland.settings.windowrule = [
      "match:class ^(discord)$, workspace ${workspace}"
    ];
  };
}
