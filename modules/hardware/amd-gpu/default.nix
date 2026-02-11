{
  enable32Bit ? true,
  enableOverdrive ? false
}:
{ ... }: {
  boot.initrd.kernelModules = [ "amdgpu" ];

  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.amdgpu.overdrive.enable = enableOverdrive;

  hardware.graphics = {
    enable = true;
    enable32Bit = enable32Bit;
  };
}
