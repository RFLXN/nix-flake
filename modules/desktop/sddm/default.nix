{ enableHidpi ? false, waylandCompositor ? "weston" }:
{ pkgs, ... }: {
  services.xserver.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    wayland.compositor = waylandCompositor;
    enableHidpi = enableHidpi;
    theme = "where_is_my_sddm_theme";
  };

  environment.systemPackages = [
    (pkgs.where-is-my-sddm-theme.override {
      themeConfig.General = {
        background = "#000000";
        backgroundMode = "fill";
      };
    })
  ];
}
