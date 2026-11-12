{ isBtrfs ? false, isRootless ? false, containersAsService ? {}, persistPath ? null }:
{ lib, username, defaultPersistPath, ... }:
let
  path = if persistPath != null then persistPath else defaultPersistPath;
in
{
  users.users.${username}.extraGroups = lib.mkIf (!isRootless) [ "docker" ];
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    storageDriver = lib.mkIf isBtrfs "btrfs";
    rootless = lib.mkIf isRootless {
      enable = true;
      setSocketVariable = true;
    };
  };

  virtualisation.oci-containers = lib.mkIf (containersAsService != {}) {
    backend = "docker";
    containers = containersAsService;
  };

  environment.persistence.${path}.directories = [ "/var/lib/docker" ];
}
