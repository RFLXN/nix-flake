{ ... }: {
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";

    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = import ./containers.nix;
  };
}