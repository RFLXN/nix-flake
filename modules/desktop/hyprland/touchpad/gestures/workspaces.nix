{  }:
{ username, ... }:
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings = {
    gesture = [
      "3, horizontal, workspace"
    ];
  };
}
