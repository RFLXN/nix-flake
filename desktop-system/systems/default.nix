{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ./impermanence.nix
    ./network.nix
    ./users.nix
    ./zram-swap.nix
    ./nix.nix
  ];
}