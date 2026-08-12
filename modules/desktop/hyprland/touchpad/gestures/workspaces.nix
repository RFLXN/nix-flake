{  }:
{ username, ... }:
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings = {
    gesture = [
      {
        fingers = 3;
        direction = "horizontal";
        action = "workspace";
      }
    ];
  };
}
