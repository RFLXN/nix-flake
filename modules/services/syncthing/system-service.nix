{ devices, folders, persistPath ? null }:
{ lib, username, defaultPersistPath ? null, ... }:
let
  path = if persistPath != null then persistPath else defaultPersistPath;
  dataDir = "/var/lib/syncthing";
in
lib.mkMerge [
  {
    services.syncthing = {
      enable = true;
      user = username;
      group = "users";
      inherit dataDir;
      settings = { inherit devices folders; };
    };
  }
  (lib.mkIf (path != null) {
    environment.persistence.${path}.directories = [ dataDir ];
    # Ensure syncthing waits for bind mount
    systemd.services.syncthing = {
      after = [ "var-lib-syncthing.mount" ];
      requires = [ "var-lib-syncthing.mount" ];
    };
  })
]
