# You should setup secure boot keys beforfe enable secure boot!
# Check: https://nix-community.github.io/lanzaboote/introduction.html

{ lib, ... }: {
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/persist/var/lib/sbctl";
  };
}