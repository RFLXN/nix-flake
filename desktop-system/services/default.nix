{ ... }: {
  imports = [
    ./desktop-environment.nix
    ./sound.nix
    ./docker.nix
    ./syncthing.nix
  ];
}