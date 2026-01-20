{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ./network.nix
    ./impermanence.nix
    ./users.nix
    ./nix.nix
  ];
}