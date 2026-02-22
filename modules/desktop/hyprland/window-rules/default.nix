{
  useDefaults = {  }:
  { username, ... }: {
    home-manager.users.${username}.wayland.windowManager.hyprland.settings = {
      windowrule = [
        "match:class .*, float 1"
        "match:float 1, size (monitor_w*0.6) (monitor_h*0.6), center 1"
      ];
    };
  };
  useFixedVesktop = import ./fixed-vesktop.nix;
  useFixedSpotify = import ./fixed-spotify.nix;
}
