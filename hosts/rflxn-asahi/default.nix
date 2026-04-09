{
  mkSystem = { inputs, modules, shared }:
    inputs.nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";

      specialArgs = {
        inherit shared modules;
        inherit (inputs)
          nixpkgs
          plasma-manager
          impermanence
          home-manager
          aarch64-widevine
          claude-code
          t3code
          astal
          ags
          battery-logger;
        inherit (shared) username;
        defaultPersistPath = "/persist";
      };

      modules = [
        inputs.apple-silicon.nixosModules.apple-silicon-support
        ./configuration.nix
      ];
    };
}
