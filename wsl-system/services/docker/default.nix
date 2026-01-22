{ ... }: {
  virtualisation.docker = {
    enable = true;

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