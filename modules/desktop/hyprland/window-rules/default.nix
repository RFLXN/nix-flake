{
  useDefaults = {  }:
  { username, ... }: {
    home-manager.users.${username}.wayland.windowManager.hyprland.settings = {
      windowrule = [
        #"match:class .*, float on"
        #"match:floating 1, size (monitor_w*0.6) (monitor_h*0.6), center on"
      ];
    };
  };
  useFixedSpotify = import ./fixed-spotify.nix;
  useFixedVesktop = import ./fixed-vesktop.nix;
  useWorkspacePseudo = import ./workspace-pseudo.nix;
}
