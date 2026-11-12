{
  enableOverdrive ? false
}:
{ ... }: {
  hardware.amdgpu = {
    initrd.enable = true;
    overdrive.enable = enableOverdrive;
  };

  services.xserver.videoDrivers = [ "amdgpu" ];
}
