{ pkgs, ... }: {
  hardware.amdgpu.overdrive.enable = true;
  hardware.enableAllFirmware = true;

  # OpenGL and Vulkan support for AMD GPUs
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}