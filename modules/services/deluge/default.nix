{
  authFile ? null,
  downloadDir ? null,
  webAuthFile ? null,
  webHost ? "0.0.0.0",
  webPort ? 8112,
  allowRemote ? false,
  persistPath ? null
}:
{
  config,
  lib,
  pkgs,
  defaultPersistPath,
  username,
  ...
}:
let
  path = if persistPath != null then persistPath else defaultPersistPath;
  dataDir = "/var/lib/deluge";
  configDir = "${dataDir}/.config/deluge";
  primaryGroup = config.users.users.${username}.group;

  effectiveDownloadDir =
    if downloadDir != null then downloadDir else "/home/${username}/data/torrents";

  baseConfig = {
    allow_remote = allowRemote;
    download_location = effectiveDownloadDir;
  };

  generatedCoreConf = pkgs.writeText "core.conf" (builtins.toJSON baseConfig);

  coreutils = "${pkgs.coreutils}/bin";
  installDir = "${coreutils}/install -d -m 0770 -o ${username} -g ${primaryGroup}";
  installSecret = "${coreutils}/install -m 0600 -o ${username} -g ${primaryGroup}";

  # Both scripts run as root ("+" prefix) because the secret files are not
  # readable by the service user.
  delugedConfig = pkgs.writeShellScript "deluged-config" ''
    set -eu
    ${installDir} ${lib.escapeShellArg configDir}
    ${installSecret} ${generatedCoreConf} ${lib.escapeShellArg "${configDir}/core.conf"}
    ${lib.optionalString (authFile != null) ''
      ${installSecret} ${lib.escapeShellArg authFile} ${lib.escapeShellArg "${configDir}/auth"}
    ''}
  '';

  delugewebConfig = pkgs.writeShellScript "delugeweb-config" ''
    set -eu
    umask 077
    web_conf=${lib.escapeShellArg "${configDir}/web.conf"}

    ${installDir} ${lib.escapeShellArg configDir}

    ${pkgs.jq}/bin/jq \
      --arg web_host ${lib.escapeShellArg webHost} \
      --argjson port ${toString webPort} \
      '{
        pwd_salt: (.pwd_salt // error("pwd_salt is missing")),
        pwd_sha1: (.pwd_sha1 // error("pwd_sha1 is missing")),
        port: $port,
        interface: $web_host
      }' ${lib.escapeShellArg webAuthFile} > "$web_conf.tmp"

    ${installSecret} "$web_conf.tmp" "$web_conf"
    ${coreutils}/rm -f "$web_conf.tmp"
  '';
in
{
  assertions = [
    {
      assertion = webAuthFile != null || webHost == "0.0.0.0";
      message = "useDeluge: webHost is written to web.conf together with the web password, so it requires webAuthFile.";
    }
  ];

  services.deluge = {
    enable = true;
    user = username;
    group = primaryGroup;
    inherit dataDir;
    declarative = false;
    openFirewall = false;
    # Not applied by the non-declarative service itself; nixpkgs still uses it
    # to create the download directory. core.conf is installed below.
    config = baseConfig;
    web = {
      enable = true;
      port = webPort;
      openFirewall = false;
    };
  };

  systemd.services.deluged.serviceConfig.ExecStartPre = lib.mkBefore [ "+${delugedConfig}" ];

  systemd.services.delugeweb.serviceConfig.ExecStartPre = lib.mkIf (webAuthFile != null) (
    lib.mkBefore [ "+${delugewebConfig}" ]
  );

  environment.persistence.${path}.directories = [ dataDir ];
}
