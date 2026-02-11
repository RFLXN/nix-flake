{
  description = "RFLXN's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, apple-silicon, impermanence, home-manager, plasma-manager, vscode-server, ... }:
  let
    # Import module library (not executed, just imported)
    modules = import ./modules;

    # Shared configuration across all hosts
    shared = {
      username = "rflxn";
      timezone = "Asia/Seoul";
      locale = "en_US.UTF-8";
    };

    # Import host's mkSystem
    rflxn-asahi = import ./hosts/rflxn-asahi;
  in {
    nixosConfigurations = {
      rflxn-asahi = rflxn-asahi.mkSystem {
        inherit nixpkgs nixpkgs-unstable modules apple-silicon impermanence home-manager plasma-manager vscode-server shared;
      };
    };
  };
}
