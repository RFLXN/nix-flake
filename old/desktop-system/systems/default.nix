{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./boot
    ./impermanence.nix
    ./network.nix
    ./users.nix
    ./zram-swap.nix
    ./nix.nix
    ./fonts.nix
    ./ime.nix
    ./bluetooth.nix
    ./amd.nix
  ];
}