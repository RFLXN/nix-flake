{ enableHidpi ? false }:
{ ... }: {
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    enableHidpi = enableHidpi;
  };
}
