{
  mkSystem = { nixpkgs, modules, impermanence, home-manager, lanzaboote, claude-code, astal, ags, hyprland, hyprshell, shared }:
    let
      system = "x86_64-linux";
    in nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit nixpkgs shared modules impermanence home-manager lanzaboote claude-code astal ags hyprland hyprshell;
        inherit (shared) username;
        defaultPersistPath = "/persist";
      };

      modules = [
        ./configuration.nix
      ];
    };
}
