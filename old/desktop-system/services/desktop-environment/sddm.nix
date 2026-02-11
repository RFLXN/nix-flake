{ ... }: {
  # Configure SDDM with Wayland
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;  # Enable Wayland for SDDM
  };

  # Deploy SDDM display configuration declaratively
  systemd.tmpfiles.rules = [
    # Create SDDM config directory
    "d /var/lib/sddm/.config 0755 sddm sddm -"
    # Copy KWin output configuration for dual monitor setup
    "C /var/lib/sddm/.config/kwinoutputconfig.json 0644 sddm sddm - ${./kwinoutputconfig.json}"
  ];
}