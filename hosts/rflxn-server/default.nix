{
  mkSystem = { nixpkgs, nixpkgs-unstable, modules, impermanence, home-manager, vscode-server, shared }:
    let
      system = "x86_64-linux";
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit shared modules pkgs-unstable impermanence home-manager vscode-server;
        inherit (shared) username;
        defaultPersistPath = "/persist";
      };

      modules = [
        ./configuration.nix
      ];
    };
}
