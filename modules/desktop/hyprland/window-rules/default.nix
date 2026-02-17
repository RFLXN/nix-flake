{
  useDefaults = {  }:
  { username, ... }: {
    home-manager.users.${username}.wayland.windowManager.hyprland.settings = {
      windowrule = [
        "float, class:.*"
      ];
    };
  };
  useFixedVesktop = import ./fixed-vesktop.nix;
  useFixedSpotify = import ./fixed-spotify.nix;
}