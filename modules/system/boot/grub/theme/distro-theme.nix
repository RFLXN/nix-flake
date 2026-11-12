# Args -> NixOS Module
{ name ? "nixos" }:

{
  distro-grub-themes,
  lib,
  pkgs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  themePackageName = "${name}-grub-theme";
  themePackages = distro-grub-themes.packages.${system} or { };
  hasTheme = builtins.hasAttr themePackageName themePackages;
  themePackage = builtins.getAttr themePackageName themePackages;
in
{
  assertions = [
    {
      assertion = hasTheme;
      message = "distro-grub-themes does not provide theme '${name}' for ${system}.";
    }
  ];

  boot.loader.grub = lib.mkIf hasTheme {
    theme = themePackage;
    splashImage = "${themePackage}/splash_image.jpg";
  };
}
