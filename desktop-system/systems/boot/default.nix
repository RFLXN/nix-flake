{ ... }: {
  boot = {
    loader.systemd-boot.enable = false; # for using grub
    loader.efi.canTouchEfiVariables = true;
    # Enable early KMS for AMD GPU - smoother transitions, no black screen
    initrd.kernelModules = [ "amdgpu" ];
  };

  imports = [
    ./grub.nix
    ./plymouth.nix
  ];
}