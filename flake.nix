{
  description = "RFLXN's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server.url = "github:nix-community/nixos-vscode-server";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    distro-grub-themes = {
      url = "github:AdisonCavani/distro-grub-themes";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    aarch64-widevine = {
      url = "github:epetousis/nixos-aarch64-widevine";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-desktop = {
      url = "github:aaddrick/claude-desktop-debian";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    codex-cli-nix = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    codex-desktop = {
      url = "github:ilysenko/codex-desktop-linux";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dank-material-shell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xivlauncher-rb = {
      url = "github:RFLXN/XIVLauncher.Core/RB-patched";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xivmitm-nix = {
      url = "github:RFLXN/XivMitmLatencyMitigator-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, ... }: let
    # Import module library (not executed, just imported)
    modules = import ./modules;

    # Shared configuration across all hosts
    shared = {
      username = "rflxn";
      timezone = "Asia/Seoul";
      locale = "en_US.UTF-8";

      git = {
        name = "RFLXN";
        email = "solid2113@naver.com";
      };

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
        inherit inputs modules shared;
      };
      rflxn-desktop = rflxn-desktop.mkSystem {
        inherit inputs modules shared;
      };
      rflxn-server = rflxn-server.mkSystem {
        inherit inputs modules shared;
      };
    };
  };
}
