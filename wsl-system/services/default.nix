{ ... }: {
  imports = [
    ./ssh.nix
    ./syncthing.nix
    ./docker
  ];
}