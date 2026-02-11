{ devices, folders }:
{ lib, username, defaultPersistPath ? null, ... }:
lib.mkMerge [
  {
    services.syncthing = {
      enable = true;
      user = username;
      settings = { inherit devices folders; };
    };
  }
  (lib.mkIf (defaultPersistPath != null) {
    environment.persistence.${defaultPersistPath}.directories = [ "/var/lib/syncthing" ];
  })
]
