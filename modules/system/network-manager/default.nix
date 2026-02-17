{ useWifi ? false, persistPath ? null }:
{ lib, username, defaultPersistPath ? null, ... }:
let
  path = if persistPath != null then persistPath else defaultPersistPath;
in
lib.mkMerge [
  {
    networking.networkmanager = {
      enable = true;
      dns = "none";
    };

    users.users.${username}.extraGroups = [ "networkmanager" ];
  }
  (lib.mkIf (path != null) {
    environment.persistence.${path}.directories = [
      "/var/lib/NetworkManager"
      "/etc/NetworkManager/system-connections"
    ];
  })
  (lib.mkIf useWifi {
    networking.networkmanager.wifi = {
      powersave = false;
      backend = "iwd";
    };

    networking.wireless.iwd = {
      enable = true;
      settings.General.EnableNetworkConfiguration = true;
    };
  })
  (lib.mkIf (useWifi && path != null) {
    environment.persistence.${path}.directories = [ "/var/lib/iwd" ];
  })
]
