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
          distro-grub-themes
          claude-code
          codex-cli-nix
          codex-desktop
          dank-material-shell
          xivlauncher-rb
          xivmitm-nix;
        inherit (shared) username;
        defaultPersistPath = "/persist";
      };

      modules = [
        ./configuration.nix
      ];
    };
}
