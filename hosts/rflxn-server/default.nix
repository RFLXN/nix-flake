{
  mkSystem = { nixpkgs, nixpkgs-unstable, modules, impermanence, home-manager, vscode-server, claude-code, shared }:
    let
      system = "x86_64-linux";
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit nixpkgs shared modules pkgs-unstable impermanence home-manager vscode-server claude-code;
        inherit (shared) username;
        defaultPersistPath = "/persist";
      };

      modules = [
        ./configuration.nix
      ];
    };
}
