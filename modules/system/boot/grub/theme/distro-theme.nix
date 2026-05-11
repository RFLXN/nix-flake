# Args -> NixOS Module
{ name ? "nixos" }:

{
  distro-grub-themes ? null,
  lib,
  pkgs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  themePackageName = "${name}-grub-theme";
  themePackages =
    if distro-grub-themes == null then
      { }
    else
      distro-grub-themes.packages.${system} or { };
  hasTheme = builtins.hasAttr themePackageName themePackages;
  themePackage = builtins.getAttr themePackageName themePackages;
in
{
  assertions =
    [
      {
        assertion = distro-grub-themes != null;
        message = "boot.grub.theme.useDistroTheme requires the distro-grub-themes flake input.";
      }
    ]
    ++ lib.optional (distro-grub-themes != null) {
      assertion = hasTheme;
      message = "distro-grub-themes does not provide theme '${name}' for ${system}.";
    };

  boot.loader.grub = lib.mkIf hasTheme {
    theme = themePackage;
    splashImage = "${themePackage}/splash_image.jpg";
  };
}
