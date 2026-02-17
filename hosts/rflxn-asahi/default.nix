{
  mkSystem = { nixpkgs, nixpkgs-unstable, modules, apple-silicon, impermanence, home-manager, plasma-manager, aarch64-widevine, claude-code, shared }:
    let
      system = "aarch64-linux";
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit nixpkgs shared modules pkgs-unstable plasma-manager impermanence home-manager aarch64-widevine claude-code;
        inherit (shared) username;
        defaultPersistPath = "/persist";
      };

      modules = [
        apple-silicon.nixosModules.apple-silicon-support
        ./configuration.nix
      ];
    };
}
