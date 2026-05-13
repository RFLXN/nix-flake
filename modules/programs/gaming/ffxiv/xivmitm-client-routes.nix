{
  gateway,
  interface,
  ranges ? null,
}:
{ lib, xivmitm-nix, ... }:
{
  imports = [
    xivmitm-nix.nixosModules.client
  ];

  services.xivMitmLatencyMitigator.client =
    {
      enable = true;
      inherit gateway interface;
    }
    // lib.optionalAttrs (ranges != null) {
      inherit ranges;
    };
}
