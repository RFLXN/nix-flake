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
          t3code
          rflxn-shell
          hyprland
          hyprshell
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
