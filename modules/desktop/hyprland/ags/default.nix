{ configDir ? null, sourceDir ? ./.config }:
{ ags, lib, pkgs, username, ... }:
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

  managedConfigDir = pkgs.runCommand "ags-config" { } ''
    mkdir -p "$out"
    cp -R "${sourceDir}/." "$out/"
  '';

  effectiveConfigDir = if configDir == null then managedConfigDir else configDir;
in
{
  home-manager.sharedModules = [ ags.homeManagerModules.default ];
  environment.systemPackages = [ agsPackage ];

  home-manager.users.${username} = {
    wayland.windowManager.hyprland.settings.exec-once = [ "ags run" ];
    home.packages = astalPackages;

    programs.ags =
      {
        enable = true;
        # Default to the managed config snapshot; override `configDir` for a custom path/symlink.
        configDir = effectiveConfigDir;
        extraPackages = astalPackages;
      };
  };
}
