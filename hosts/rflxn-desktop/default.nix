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
          lanzaboote
          claude-code
          codex-cli-nix
          codex-desktop
          t3code
          astal
          ags
          hyprland
          hyprshell;
        inherit (shared) username;
        defaultPersistPath = "/persist";
      };

      modules = [
        ./configuration.nix
      ];
    };
}
