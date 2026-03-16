{
  authFile ? null,
  downloadDir ? null,
  webPort ? 8112,
  persistPath ? null
}:
{
  config,
  lib,
  pkgs,
  defaultPersistPath ? null,
  username,
  ...
}:
let
  path = if persistPath != null then persistPath else defaultPersistPath;
  dataDir = "/var/lib/deluge";
  configDir = "${dataDir}/.config/deluge";
  configuredGroup = lib.attrByPath [ "users" "users" username "group" ] "" config;
  primaryGroup = if configuredGroup != "" then configuredGroup else "users";

  effectiveDownloadDir =
    if downloadDir != null then downloadDir else "/home/${username}/data/torrents";

  baseConfig = {
    allow_remote = true;
    download_location = effectiveDownloadDir;
  };

  generatedCoreConf = pkgs.writeText "core.conf" (builtins.toJSON baseConfig);
in
lib.mkMerge [
  {
    services.deluge = {
      enable = true;
      user = username;
      group = primaryGroup;
      inherit dataDir;
      declarative = false;
      openFirewall = false;
      config = baseConfig;
      web = {
        enable = true;
        port = webPort;
        openFirewall = false;
      };
    };

    systemd.services.deluged = lib.mkIf (authFile != null) {
      preStart = lib.mkBefore ''
        ${pkgs.coreutils}/bin/install -d -m 0770 -o ${username} -g ${primaryGroup} ${lib.escapeShellArg configDir}
        ${pkgs.coreutils}/bin/cp ${generatedCoreConf} ${lib.escapeShellArg "${configDir}/core.conf"}
        ${pkgs.coreutils}/bin/cp ${lib.escapeShellArg authFile} ${lib.escapeShellArg "${configDir}/auth"}
        ${pkgs.coreutils}/bin/chown ${username}:${primaryGroup} ${lib.escapeShellArg "${configDir}/core.conf"} ${lib.escapeShellArg "${configDir}/auth"}
        ${pkgs.coreutils}/bin/chmod 0600 ${lib.escapeShellArg "${configDir}/core.conf"} ${lib.escapeShellArg "${configDir}/auth"}
      '';

      serviceConfig.PermissionsStartOnly = true;
    };
  }

  (lib.mkIf (path != null) {
    environment.persistence.${path}.directories = [ dataDir ];
  })
]
