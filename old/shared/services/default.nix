{ ... }: {
  imports = [
    ./home-manager.nix
    ./tailscale.nix
    ./direnv.nix
    ./ssh.nix
  ];
}