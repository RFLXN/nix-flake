{ pkgs, ... }: 
let
  # Available variants: nixos, arch, ubuntu, fedora, debian, manjaro,
  # opensuse-generic, opensuse-tumbleweed, redhat, endeavouros, linux-mint,
  # macos, windows-dark, windows-light, gentoo, alt-linux, zorin-os, linux-generic
  hyperfluentTheme = pkgs.callPackage ./grub-theme/hyperfluent.nix {
    variant = "nixos";  # Change this to use a different variant
  };
in
{
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
    theme = hyperfluentTheme;
    gfxmodeEfi = "1920x1080";
    gfxmodeBios = "1920x1080";
    configurationLimit = 3;
  };
}