{
  description = "RFLXN's NixOS Home Server Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/release-25.11";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixos-wsl, home-manager, ... }: {
    # Export system builder function
    mkSystem = { shared }: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          hostNames = shared.data.hostNames;
          username = shared.data.username;
        };
        modules = [
          nixos-wsl.nixosModules.default
          home-manager.nixosModules.home-manager
          shared.modules
          { wsl.enable = true; }
        ] ++ [
          ./systems
          ./services
        ];
      };
  };
}
