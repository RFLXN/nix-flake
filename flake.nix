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

    aarch64-widevine.url = "github:epetousis/nixos-aarch64-widevine";

    claude-code.url = "github:sadjow/claude-code-nix";

    astal.url = "github:aylur/astal";

    ags.url = "github:aylur/ags";

  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    apple-silicon,
    impermanence,
    home-manager,
    plasma-manager,
    vscode-server,
    lanzaboote,
    aarch64-widevine,
    claude-code,
    astal,
    ags,
    ...
  }: let
    # Import module library (not executed, just imported)
    modules = import ./modules;

    # Shared configuration across all hosts
    shared = {
      username = "rflxn";
      timezone = "Asia/Seoul";
      locale = "en_US.UTF-8";

      syncthing-devices = {
        rflxn-server = { id = "TWGALLT-3IIATII-6SL3P34-L5RTUHA-KDIJHHP-CV3F5XL-77R3272-FKASKAN"; };
        rflxn-desktop = { id = "5G6J27Y-LHS63PQ-CO42X5W-LJY5D7X-GLITAWP-SQHKCTV-B5F47CS-3PRN5AA"; };
        rflxn-asahi = { id = "EKTGOJY-6UF4WT2-VZXY3GI-UV7KI5N-XYOS6OQ-Z6FZSYK-D47SBBC-JKDNLAW"; };
      };
    };

    # Import host's mkSystem
    rflxn-asahi = import ./hosts/rflxn-asahi;
    rflxn-desktop = import ./hosts/rflxn-desktop;
    rflxn-server = import ./hosts/rflxn-server;
  in {
    nixosConfigurations = {
      rflxn-asahi = rflxn-asahi.mkSystem {
        inherit nixpkgs nixpkgs-unstable modules apple-silicon impermanence home-manager plasma-manager aarch64-widevine claude-code ags shared;
      };
      rflxn-desktop = rflxn-desktop.mkSystem {
        inherit nixpkgs nixpkgs-unstable modules impermanence home-manager lanzaboote claude-code astal ags shared;
      };
      rflxn-server = rflxn-server.mkSystem {
        inherit nixpkgs nixpkgs-unstable modules impermanence home-manager vscode-server claude-code shared;
      };
    };
  };
}
