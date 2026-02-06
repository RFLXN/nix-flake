{ ... }: {
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    enableOnBoot = true;

    daemon.settings = {
      dns = [ "1.1.1.1" "1.0.0.1" ];
      iptables = true;
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = import ./containers.nix;
  };
}