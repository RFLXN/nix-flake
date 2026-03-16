{
  authFile ? null,
  downloadDir ? null,
  webPort ? 8112,
  persistPath ? null
}:
{
  config,
  lib,
  defaultPersistPath ? null,
  username,
  ...
}:
let
  path = if persistPath != null then persistPath else defaultPersistPath;
  dataDir = "/var/lib/deluge";
  configuredGroup = lib.attrByPath [ "users" "users" username "group" ] "" config;
  primaryGroup = if configuredGroup != "" then configuredGroup else "users";

  effectiveDownloadDir =
    if downloadDir != null then downloadDir else "/home/${username}/data/torrents";

  baseConfig = {
    allow_remote = true;
    download_location = effectiveDownloadDir;
  };
in
lib.mkMerge [
  {
    services.deluge = {
      enable = true;
      user = username;
      group = primaryGroup;
      inherit dataDir;
      declarative = authFile != null;
      openFirewall = false;
      config = baseConfig;
      web = {
        enable = true;
        port = webPort;
        openFirewall = false;
      };
    } // lib.optionalAttrs (authFile != null) {
      inherit authFile;
    };
  }

  (lib.mkIf (path != null) {
    environment.persistence.${path}.directories = [ dataDir ];
  })
]
