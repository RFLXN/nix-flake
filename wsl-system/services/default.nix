{ ... }: {
  imports = [
    ./ssh.nix
    ./syncthing.nix
    ./docker
    ./jetbrains.nix
  ];
}