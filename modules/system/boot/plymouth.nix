{ theme ? "breeze", enableQuietBoot ? true }:
{ lib, ... }: lib.mkMerge [
  {
    boot.plymouth = {
      enable = true;
      inherit theme;
    };
  }
  (lib.mkIf enableQuietBoot {
    boot = {
      consoleLogLevel = 0;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "udev.log_level=0"
        "systemd.show_status=false"
      ];
    };
  })
]
