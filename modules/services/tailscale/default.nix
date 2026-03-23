{ persistPath ? null, enableSystemTray ? false }:
{ lib, pkgs, username, defaultPersistPath ? null, ... }:
let
  path = if persistPath != null then persistPath else defaultPersistPath;
in
lib.mkMerge [
  { services.tailscale.enable = true; }
  (lib.mkIf enableSystemTray {
    services.tailscale.extraSetFlags = [ "--operator=${username}" ];

    systemd.user.services.tailscale-systray = {
      description = "Tailscale Systray";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe pkgs.tailscale} systray";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  })
  (lib.mkIf (path != null) {
    environment.persistence.${path}.directories = [ "/var/lib/tailscale" ];
  })
]
