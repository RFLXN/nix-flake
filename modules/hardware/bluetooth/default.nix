{ persistPath ? null }:
{ lib, defaultPersistPath, ... }:
let
  path = if persistPath != null then persistPath else defaultPersistPath;
in
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;

    settings.General = {
      Experimental = true;
      FastConnectable = true;
    };
  };

  services.upower.enable = lib.mkDefault true;

  environment.persistence.${path}.directories = [ "/var/lib/bluetooth" ];
}
