{ persistPath ? null }:
{ defaultPersistPath, ... }:
let
  path = if persistPath != null then persistPath else defaultPersistPath;
in
{
  services.flatpak.enable = true;

  environment.persistence.${path}.directories = [ "/var/lib/flatpak" ];
}
