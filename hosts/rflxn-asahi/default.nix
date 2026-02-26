{
  mkSystem = { nixpkgs, modules, apple-silicon, impermanence, home-manager, plasma-manager, aarch64-widevine, claude-code, ags, battery-logger, shared }:
    let
      system = "aarch64-linux";
    in nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit nixpkgs shared modules plasma-manager impermanence home-manager aarch64-widevine claude-code ags battery-logger;
        inherit (shared) username;
        defaultPersistPath = "/persist";
      };

      modules = [
        apple-silicon.nixosModules.apple-silicon-support
        ./configuration.nix
      ];
    };
}
