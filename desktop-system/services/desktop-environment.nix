{ ... }: {
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;

  security.rtkit.enable = true;
}