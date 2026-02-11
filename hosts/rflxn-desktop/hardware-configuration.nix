{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/78b6199d-0161-42e2-9dbd-34c69d72d54e";
      fsType = "btrfs";
      options = [ "subvol=@root" "compress=zstd" "noatime" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/78b6199d-0161-42e2-9dbd-34c69d72d54e";
      fsType = "btrfs";
      options = [ "subvol=@nix" "compress=zstd" "noatime" ];
    };

  fileSystems."/persist" =
    { device = "/dev/disk/by-uuid/78b6199d-0161-42e2-9dbd-34c69d72d54e";
      fsType = "btrfs";
      options = [ "subvol=@persist" "compress=zstd" "noatime" ];
      neededForBoot = true;
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/7176-D38F";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  fileSystems."/mnt/shared" =
    { device = "/dev/disk/by-uuid/d12aaa25-103d-446f-acc4-8814fabc8300";
      fsType = "ext4";
    };

  swapDevices =
    [
      {
        device = "/dev/disk/by-uuid/bdd2c8da-8cea-4f65-8cda-f73b6385c7b6";
        priority = 5;
      }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
