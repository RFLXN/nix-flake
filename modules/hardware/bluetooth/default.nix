{ persistPath ? null }:
{ lib, defaultPersistPath ? null, ... }:
let
  path = if persistPath != null then persistPath else defaultPersistPath;
in
lib.mkMerge [
  {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;

      settings = {
        General = {
          Experimental = true;
          FastConnectable = true;
        };
        Policy.AutoEnable = true;
      };
    };
  }
  (lib.mkIf (path != null) {
    environment.persistence.${path}.directories = [ "/var/lib/bluetooth" ];
  })
]
