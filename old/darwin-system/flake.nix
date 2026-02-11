{
  description = "RFLXN's nix-darwin Macbook Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";
    darwin.url = "github:lnl7/nix-darwin/nix-darwin-25.11";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = { self, nixpkgs, darwin, home-manager, homebrew, ... }: {
    # Export system builder function
    mkSystem = { shared }: darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          username = shared.data.username;
          hostNames = shared.data.hostNames;
        };
        modules = [
          home-manager.darwinModules.home-manager
          homebrew.darwinModules.nix-homebrew
          shared.modules
        ] ++ [
          ./systems
          ./services
          ./programs
          ./packages
        ];
      };
  };
}
