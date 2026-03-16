{
  authFile ? null,
  downloadDir ? null,
  webAuthFile ? null,
  webHost ? "0.0.0.0",
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

    systemd.services.delugeweb = lib.mkIf (webAuthFile != null) {
      preStart = lib.mkBefore ''
        web_auth_file=${lib.escapeShellArg webAuthFile}
        web_conf=${lib.escapeShellArg "${configDir}/web.conf"}

        ${pkgs.coreutils}/bin/install -d -m 0770 -o ${username} -g ${primaryGroup} ${lib.escapeShellArg configDir}

        pwd_salt="$(${pkgs.jq}/bin/jq -er '.pwd_salt' "$web_auth_file")"
        pwd_sha1="$(${pkgs.jq}/bin/jq -er '.pwd_sha1' "$web_auth_file")"

        ${pkgs.jq}/bin/jq -n \
          --arg pwd_salt "$pwd_salt" \
          --arg pwd_sha1 "$pwd_sha1" \
          --arg web_host ${lib.escapeShellArg webHost} \
          --argjson port ${toString webPort} \
          '{
            "pwd_salt": $pwd_salt,
            "pwd_sha1": $pwd_sha1,
            "port": $port,
            "interface": $web_host
          }' > "$web_conf"

        ${pkgs.coreutils}/bin/chown ${username}:${primaryGroup} "$web_conf"
        ${pkgs.coreutils}/bin/chmod 0600 "$web_conf"
      '';

      serviceConfig.PermissionsStartOnly = true;
    };
  }

  (lib.mkIf (path != null) {
    environment.persistence.${path}.directories = [ dataDir ];
  })
]
