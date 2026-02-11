{ ... }: {
  imports = [
    ./ssh.nix
    ./jetbrains.nix
    ./vscode-server.nix
    ./syncthing.nix
    ./docker
    ./tailscale.nix
  ];
}