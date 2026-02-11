{ pkgs, ... }: {
  # Enable X server (still needed for XWayland compatibility)
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
    ];
  };

  security.rtkit.enable = true;

  imports = [
    ./kde-plasma-6.nix
    ./sddm.nix
  ];
}