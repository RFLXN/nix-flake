{ ... }: {
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";

    daemon.settings = {
      dns = [ "1.1.1.1" "1.0.0.1" ];
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = import ./containers.nix;
  };
}