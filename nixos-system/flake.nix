{
  description = "RFLXN's NixOS Home Server Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    impermanence.url = "github:nix-community/impermanence";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, impermanence, vscode-server, home-manager, ... }: {
    # Export system builder function
    mkSystem = { shared }: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          hostNames = shared.data.hostNames;
          username = shared.data.username;
        };
        modules = [
          impermanence.nixosModules.impermanence
          vscode-server.nixosModules.default
          home-manager.nixosModules.home-manager
          shared.modules  # Import shared module configurations
        ] ++ [
          ./systems
          ./services
        ];
      };
  };
}
