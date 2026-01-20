{
  description = "RFLXN's Unified Multi-System Nix Configuration";

  inputs = {
    # Sub-flakes (local)
    shared.url = "path:./shared";
    nixos-system.url = "path:./nixos-system";
    darwin-system.url = "path:./darwin-system";
  };

  outputs = {
    self,
    shared,
    nixos-system,
    darwin-system,
    ...
  }: {

    # Native NixOS Home Server (x86_64-linux)
    nixosConfigurations.rflxn-server = nixos-system.mkSystem {
      inherit shared;
    };

    # nix-darwin Macbook (aarch64-darwin)
    darwinConfigurations.rflxn-macbook = darwin-system.mkSystem {
      inherit shared;
    };
  };
}
