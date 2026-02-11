{ ... }: {
  boot = {
    loader.systemd-boot = {
      enable = false; # for lanzaboote. see ./secure-boot.nix
      configurationLimit = 10;
    };

    loader.efi.canTouchEfiVariables = true;
    initrd.kernelModules = [ "amdgpu" ];

    kernelParams = [];
  };

  imports = [
    # ./grub.nix
    ./plymouth.nix
    ./secure-boot.nix
  ];
}