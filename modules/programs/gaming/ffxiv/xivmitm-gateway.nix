{
  listenPort ? 10514,
  incomingInterface ? null,
  outgoingInterface ? incomingInterface,
  clientCidr ? null,
  portRange ? "1024:65535",
  ranges ? null,
  manageDocker ? false,
  runContainer ? false,
  ffxivDx11Exe ? null,
  dataDir ? null,
  listenAddress ? null,
  measurePing ? null,
  webStatistics ? null,
  extraMitmArgs ? null,
}:
{ lib, xivmitm-nix, ... }:
{
  imports = [
    xivmitm-nix.nixosModules.server
  ];

  services.xivMitmLatencyMitigator.server =
    {
      enable = true;
      inherit
        listenPort
        incomingInterface
        outgoingInterface
        clientCidr
        portRange
        manageDocker
        runContainer
        ;
    }
    // lib.optionalAttrs (ranges != null) {
      inherit ranges;
    }
    // lib.optionalAttrs (ffxivDx11Exe != null) {
      inherit ffxivDx11Exe;
    }
    // lib.optionalAttrs (dataDir != null) {
      inherit dataDir;
    }
    // lib.optionalAttrs (listenAddress != null) {
      inherit listenAddress;
    }
    // lib.optionalAttrs (measurePing != null) {
      inherit measurePing;
    }
    // lib.optionalAttrs (webStatistics != null) {
      inherit webStatistics;
    }
    // lib.optionalAttrs (extraMitmArgs != null) {
      inherit extraMitmArgs;
    };
}
