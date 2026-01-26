{ ... }: {
  boot = {
    plymouth = {
      enable = true;
      theme = "breeze";  # Clean KDE-style theme (alternative: "bgrt" for logo)
    };

    # Silent boot - completely hide boot logs
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "udev.log_level=0"
      "systemd.show_status=auto"
    ];
  };
}