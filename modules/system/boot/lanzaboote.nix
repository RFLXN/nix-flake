# You should setup secure boot keys before enabling secure boot!
# Check: https://nix-community.github.io/lanzaboote/introduction.html
{ persistPath ? null }:
{ pkgs, lib, lanzaboote, defaultPersistPath ? null, ... }:
let
  path = if persistPath != null then persistPath else defaultPersistPath;
in {
  imports = [ lanzaboote.nixosModules.lanzaboote ];

  config = lib.mkMerge [
    {
      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };

      environment.systemPackages = [ pkgs.sbctl ];
    }
    (lib.mkIf (path != null) {
      environment.persistence.${path}.directories = [ "/var/lib/sbctl" ];
    })
  ];
}
