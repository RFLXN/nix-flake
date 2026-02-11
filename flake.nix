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

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, apple-silicon, impermanence, home-manager, plasma-manager, vscode-server, lanzaboote, ... }:
  let
    # Import module library (not executed, just imported)
    modules = import ./modules;

    # Shared configuration across all hosts
    shared = {
      username = "rflxn";
      timezone = "Asia/Seoul";
      locale = "en_US.UTF-8";

      syncthing-devices = {
        rflxn-server = { id = "JOLVNXJF-K72AXIA-WPPXCKO-4UQIVAJ-YNFRLLH-RV5UXL5-ENMRFYQ-WACO5QD"; };
        rflxn-desktop = { id = "63DJZE5-GC3RSIV-UANZZEE-O4JL4EV-4CDOGPD-HCSDGHP-ZX4XFRI-ZA47DAM"; };
        rflxn-asahi = { id = "BBTTEGG-W5SCDBV-ZTBI4ZZ-FQQR3AE-HEAJJGN-NAN7CM2-WFYEV37-YOEDIA3"; };
      };
    };

    # Import host's mkSystem
    rflxn-asahi = import ./hosts/rflxn-asahi;
    rflxn-desktop = import ./hosts/rflxn-desktop;
    rflxn-server = import ./hosts/rflxn-server;
  in {
    nixosConfigurations = {
      rflxn-asahi = rflxn-asahi.mkSystem {
        inherit nixpkgs nixpkgs-unstable modules apple-silicon impermanence home-manager plasma-manager shared;
      };
      rflxn-desktop = rflxn-desktop.mkSystem {
        inherit nixpkgs nixpkgs-unstable modules impermanence home-manager plasma-manager lanzaboote shared;
      };
      rflxn-server = rflxn-server.mkSystem {
        inherit nixpkgs nixpkgs-unstable modules impermanence home-manager vscode-server shared;
      };
    };
  };
}
