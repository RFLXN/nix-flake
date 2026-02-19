{
  useDefaults = { }:
  { username, ... }:
  {
    home-manager.users.${username}.wayland.windowManager.hyprland.settings = {
      input.touchpad = {
        natural_scroll = true;
        scroll_factor = 0.25;
        disable_while_typing = true;
        clickfinger_behavior = 1;
        # tap_button_map = "lrm";
        "tap-to-click" = false;
        "tap-and-drag" = true;
        middle_button_emulation = false;
      };
    };
  };

  gestures = import ./gestures;
}
