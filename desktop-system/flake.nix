{
  description = "RFLXN's NixOS Desktop Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    impermanence.url = "github:nix-community/impermanence";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, impermanence, home-manager, ... }: {
    # Export system builder function
    mkSystem = { shared }: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          hostNames = shared.data.hostNames;
          username = shared.data.username;
        };
        modules = [
          impermanence.nixosModules.impermanence
          home-manager.nixosModules.home-manager
          shared.modules  # Import shared module configurations
        ] ++ [
          ./systems
          ./services
          ./packages
          ./programs
        ];
      };
  };
}
