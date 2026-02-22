{ persistPath ? null }:
{ lib, defaultPersistPath ? null, ... }:
let
  path = if persistPath != null then persistPath else defaultPersistPath;
in
lib.mkMerge [
  { services.flatpak.enable = true; }
  (lib.mkIf (path != null) {
    environment.persistence.${path}.directories = [ "/var/lib/flatpak" ];
  })
]
