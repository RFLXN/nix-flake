{
  description = "RFLXN's NixOS Desktop Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    impermanence.url = "github:nix-community/impermanence";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote/v1.0.0";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, impermanence, home-manager, lanzaboote, ... }: {
    # Export system builder function
    mkSystem = { shared }: let
      system = "x86_64-linux";
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        hostNames = shared.data.hostNames;
        username = shared.data.username;
        inherit pkgs-unstable;
      };
      modules = [
        impermanence.nixosModules.impermanence
        home-manager.nixosModules.home-manager
        lanzaboote.nixosModules.lanzaboote
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
