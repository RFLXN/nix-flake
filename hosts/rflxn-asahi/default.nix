{
  mkSystem = { nixpkgs, nixpkgs-unstable, modules, apple-silicon, impermanence, home-manager, plasma-manager, aarch64-widevine, shared }:
    let
      system = "aarch64-linux";
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit shared modules pkgs-unstable plasma-manager impermanence home-manager aarch64-widevine;
        inherit (shared) username;
        defaultPersistPath = "/persist";
      };

      modules = [
        apple-silicon.nixosModules.apple-silicon-support
        ./configuration.nix
      ];
    };
}
