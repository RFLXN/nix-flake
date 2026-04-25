{
  mkSystem = { inputs, modules, shared }:
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        inherit shared modules;
        inherit (inputs)
          nixpkgs
          impermanence
          home-manager
          vscode-server
          codex-cli-nix
          claude-code;
        inherit (shared) username;
        defaultPersistPath = "/persist";
      };

      modules = [
        ./configuration.nix
      ];
    };
}
