{
  agsPackage ? null,
  autostartCommand ? "ags run",
  enableAutostart ? true,
  layout ? null,
  package ? null,
  runtimePackages ? null,
}:
{ lib, pkgs, rflxn-shell, username, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  agsPackages = rflxn-shell.inputs.ags.packages.${system};
  astalPackages = with agsPackages; [
    astal4
    io
    apps
    battery
    bluetooth
    hyprland
    mpris
    network
    notifd
    tray
    wireplumber
    powerprofiles
  ];
  defaultRuntimePackages = astalPackages ++ [
    pkgs.libadwaita
    pkgs.libsoup_3
    pkgs.gtk4
    pkgs.papirus-icon-theme
    pkgs.upower
  ];
  resolvedRuntimePackages =
    if runtimePackages == null then
      defaultRuntimePackages
    else
      runtimePackages;
  defaultAgsPackage = (agsPackages.default.override {
    extraPackages = resolvedRuntimePackages;
  }).overrideAttrs (_oldAttrs: {
    dontWrapQtApps = true;
  });
  agsShellConfig =
    {
      enable = true;
      agsPackage =
        if agsPackage == null then
          defaultAgsPackage
        else
          agsPackage;
      runtimePackages = resolvedRuntimePackages;
    }
    // lib.optionalAttrs (layout != null) {
      inherit layout;
    }
    // lib.optionalAttrs (package != null) {
      inherit package;
    }
    ;
in
{
  imports = [ rflxn-shell.nixosModules.ags-shell ];

  home-manager.users.${username} = {
    programs.ags-shell = agsShellConfig;

    wayland.windowManager.hyprland.settings = lib.mkIf enableAutostart {
      exec-once = [ autostartCommand ];
    };
  };
}
