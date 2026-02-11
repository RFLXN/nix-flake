{ devices, folders, persistPath ? null }:
{ lib, username, defaultPersistPath ? null, ... }:
let
  path = if persistPath != null then persistPath else defaultPersistPath;
in
lib.mkMerge [
  {
    services.syncthing = {
      enable = true;
      user = username;
      settings = { inherit devices folders; };
    };
  }
  (lib.mkIf (path != null) {
    environment.persistence.${path}.directories = [ "/var/lib/syncthing" ];
  })
]
