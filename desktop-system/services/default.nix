{ ... }: {
  imports = [
    ./desktop-environment
    ./sound.nix
    ./docker.nix
    ./syncthing.nix
    ./keyd.nix
    ./lact.nix
    ./openrazer.nix
  ];
}