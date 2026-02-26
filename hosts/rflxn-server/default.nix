{
  mkSystem = { nixpkgs, modules, impermanence, home-manager, vscode-server, claude-code, shared }:
    let
      system = "x86_64-linux";
    in nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit nixpkgs shared modules impermanence home-manager vscode-server claude-code;
        inherit (shared) username;
        defaultPersistPath = "/persist";
      };

      modules = [
        ./configuration.nix
      ];
    };
}
