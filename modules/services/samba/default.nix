{ directories ? {}, persistPath ? null }:
{
  config,
  lib,
  defaultPersistPath ? null,
  username,
  ...
}:
let
  path = if persistPath != null then persistPath else defaultPersistPath;
  configuredGroup = lib.attrByPath [ "users" "users" username "group" ] "" config;
  primaryGroup = if configuredGroup != "" then configuredGroup else "users";

  shareSettings = lib.mapAttrs (_name: directory: {
    path = toString directory;
    "browseable" = "yes";
    "read only" = "no";
    "guest ok" = "no";
    "valid users" = [ username ];
    "force user" = username;
    "force group" = primaryGroup;
    "create mask" = "0644";
    "directory mask" = "0755";
  }) directories;
in
lib.mkMerge [
  {
    assertions = [
      {
        assertion = directories != {};
        message = "useSamba requires at least one entry in `directories`.";
      }
    ];

    services.samba = {
      enable = true;
      openFirewall = false;
      nmbd.enable = true;
      winbindd.enable = false;
      settings =
        {
          global = {
            security = "user";
            "map to guest" = "never";
            "invalid users" = [ "root" ];
          };
        }
        // shareSettings;
    };
  }

  (lib.mkIf (path != null) {
    environment.persistence.${path}.directories = [ "/var/lib/samba" ];
  })
]
