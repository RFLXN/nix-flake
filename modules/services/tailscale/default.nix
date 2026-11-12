{
  persistPath ? null,
  enableSystemTray ? false,
  openFirewall ? false,
}:
{ lib, pkgs, username, defaultPersistPath, ... }:
let
  path = if persistPath != null then persistPath else defaultPersistPath;
in
lib.mkMerge [
  {
    services.tailscale = {
      enable = true;
      inherit openFirewall;
    };

    environment.persistence.${path}.directories = [ "/var/lib/tailscale" ];
  }
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
]
