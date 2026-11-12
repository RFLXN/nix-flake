{ enableDaemon ? true, persistPath ? null }:
{ pkgs, lib, defaultPersistPath, ... }:
let
  path = if persistPath != null then persistPath else defaultPersistPath;
in
lib.mkMerge [
  {
    # The NixOS module installs the package and runs the upstream lactd unit.
    services.lact.enable = enableDaemon;

    environment.systemPackages = lib.optionals (!enableDaemon) [ pkgs.lact ];
  }
  (lib.mkIf enableDaemon {
    # lactd keeps fan curves and tuning in /etc/lact/config.yaml.
    environment.persistence.${path}.directories = [ "/etc/lact" ];
  })
]
