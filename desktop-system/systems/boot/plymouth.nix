{ ... }: {
  boot = {
    plymouth = {
      enable = true;
      theme = "breeze";
    };
    
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "udev.log_level=0"
      "systemd.show_status=false"
    ];
  };
}