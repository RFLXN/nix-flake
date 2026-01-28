{ pkgs, ... }: {
  # Enable X server (still needed for XWayland compatibility)
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Enable KDE Plasma 6 (uses Wayland by default)
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    kate
    konsole
    okular
  ];

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
    ];
  };

  security.rtkit.enable = true;

  imports = [
    ./sddm.nix
  ];
}