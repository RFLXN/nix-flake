{ useWifi ? false, persistPath ? null }:
{ lib, username, defaultPersistPath, ... }:
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

    environment.persistence.${path}.directories = [
      "/var/lib/NetworkManager"
      "/etc/NetworkManager/system-connections"
    ];
  }
  (lib.mkIf useWifi {
    # NetworkManager enables iwd itself for this backend and keeps doing the
    # address and route setup, so iwd must not run its own network
    # configuration on the same interface.
    networking.networkmanager.wifi = {
      powersave = false;
      backend = "iwd";
    };

    environment.persistence.${path}.directories = [ "/var/lib/iwd" ];
  })
]
