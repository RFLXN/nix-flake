{ pkgs, ... }: {
  # Enable X server (still needed for XWayland compatibility)
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Enable KDE Plasma 6 (uses Wayland by default)
  services.desktopManager.plasma6.enable = true;

  security.rtkit.enable = true;

  imports = [
    ./sddm.nix
  ];
}