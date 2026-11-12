{
  devices,
  folders,
  webHost ? "127.0.0.1",
  webPort ? 8384,
  persistPath ? null
}:
{ config, username, defaultPersistPath, ... }:
let
  path = if persistPath != null then persistPath else defaultPersistPath;
  dataDir = "/var/lib/syncthing";
  group = config.users.users.${username}.group;
in
{
  services.syncthing = {
    enable = true;
    user = username;
    inherit group dataDir;
    guiAddress = "${webHost}:${toString webPort}";
    settings = { inherit devices folders; };
  };

  # Syncthing runs as the repo user, so the persisted directory must not be
  # created root-owned on a fresh install.
  environment.persistence.${path}.directories = [
    {
      directory = dataDir;
      user = username;
      inherit group;
      mode = "0700";
    }
  ];

  # Wait for the persistence bind mount.
  systemd.services.syncthing.unitConfig.RequiresMountsFor = [ dataDir ];
}
