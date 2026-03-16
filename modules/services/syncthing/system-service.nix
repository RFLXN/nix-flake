{
  devices,
  folders,
  webHost ? "0.0.0.0",
  webPort ? 8384,
  persistPath ? null
}:
{ lib, username, defaultPersistPath ? null, ... }:
let
  path = if persistPath != null then persistPath else defaultPersistPath;
  dataDir = "/var/lib/syncthing";
  guiAddress = "${webHost}:${toString webPort}";
in
lib.mkMerge [
  {
    services.syncthing = {
      enable = true;
      user = username;
      group = "users";
      inherit dataDir;
      inherit guiAddress;
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
