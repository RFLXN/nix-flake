{
  mkSystem = { nixpkgs, nixpkgs-unstable, modules, apple-silicon, impermanence, home-manager, plasma-manager, vscode-server, shared }:
    let
      system = "aarch64-linux";
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit shared modules pkgs-unstable plasma-manager vscode-server impermanence home-manager;
        inherit (shared) username;
        defaultPersistPath = "/persist";
      };

      modules = [
        apple-silicon.nixosModules.apple-silicon-support
        ./configuration.nix
      ];
    };
}
