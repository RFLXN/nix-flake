{ ... }: {
  imports = [
    ./desktop-environment
    ./sound
    ./docker.nix
    ./syncthing.nix
    ./keyd.nix
    ./lact.nix
    ./openrazer.nix
    ./gpu-screen-recorder.nix
  ];
}