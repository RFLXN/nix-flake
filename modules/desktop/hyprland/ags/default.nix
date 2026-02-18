{ sourceDir ? null }:
{ ags, pkgs, username, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  astalPackagesSet = ags.inputs.astal.packages.${system};

  astalPackages = with astalPackagesSet; [
    apps
    battery
    bluetooth
    hyprland
    mpris
    network
    notifd
    tray
    wireplumber
  ];

  agsPackage = ags.packages.${system}.default;
  agsSourceDir =
    if sourceDir == null then
      "/home/${username}/nix/my-ags"
    else
      toString sourceDir;
in
{
  home-manager.sharedModules = [ ags.homeManagerModules.default ];
  environment.systemPackages = [ agsPackage ];

  home-manager.users.${username} = { config, ... }: {
    wayland.windowManager.hyprland.settings.exec-once = [ "ags run" ];
    home.packages = astalPackages;

    # Keep AGS on its default path (~/.config/ags) for live local iteration.
    #xdg.configFile."ags".source = config.lib.file.mkOutOfStoreSymlink agsSourceDir;

    programs.ags = {
      enable = true;
      extraPackages = astalPackages;
    };
  };
}
