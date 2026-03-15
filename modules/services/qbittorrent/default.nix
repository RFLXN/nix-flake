{
  downloadDir ? null,
  incompleteDir ? null,
  profileDir ? "/var/lib/qBittorrent",
  webuiPort ? 8080,
  torrentingPort ? null,
  passwordFile ? null,
  serverConfig ? {},
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
  configuredGroup = lib.attrByPath [ "users" "users" username "group" ] "" config;
  primaryGroup = if configuredGroup != "" then configuredGroup else "users";
  configPath = "${profileDir}/qBittorrent/config/qBittorrent.conf";

  effectiveDownloadDir =
    if downloadDir != null then downloadDir else "/home/${username}/data/torrents";

  baseServerConfig = lib.recursiveUpdate
    {
      LegalNotice = {
        Accepted = true;
      };

      BitTorrent = {
        Session = {
          DefaultSavePath = effectiveDownloadDir;
        };
      };
    }
    (
      (lib.optionalAttrs (passwordFile != null) {
        Preferences = {
          WebUI = {
            Username = username;
          };
        };
      })
      // (lib.optionalAttrs (incompleteDir != null) {
        BitTorrent = {
          Session = {
            TempPath = incompleteDir;
            TempPathEnabled = true;
          };
        };
      })
    );
in
lib.mkMerge [
  {
    assertions = [
      {
        assertion = !(passwordFile != null && lib.hasAttrByPath [ "Preferences" "WebUI" "Password_PBKDF2" ] serverConfig);
        message = "useQBittorrent cannot use both `passwordFile` and `serverConfig.Preferences.WebUI.Password_PBKDF2`.";
      }
    ];

    services.qbittorrent = {
      enable = true;
      user = username;
      group = primaryGroup;
      inherit profileDir webuiPort torrentingPort;
      openFirewall = false;
      serverConfig = lib.recursiveUpdate baseServerConfig serverConfig;
    };

    systemd.services.qbittorrent = lib.mkMerge [
      {
        # qBittorrent's upstream NixOS unit hides /home by default, which breaks
        # download paths under /home/${username}.
        serviceConfig.ProtectHome = lib.mkForce false;
      }

      (lib.mkIf (passwordFile != null) {
        preStart = lib.mkAfter ''
          config_path=${lib.escapeShellArg configPath}
          password_file=${lib.escapeShellArg passwordFile}

          if [ -L "$config_path" ]; then
            config_target="$(${pkgs.coreutils}/bin/readlink -f "$config_path")"
            ${pkgs.coreutils}/bin/cp --remove-destination "$config_target" "$config_path"
          elif [ ! -e "$config_path" ]; then
            ${pkgs.coreutils}/bin/install -D -m 0600 /dev/null "$config_path"
          fi

          password="$(${pkgs.coreutils}/bin/tr -d '\r\n' < "$password_file")"

          if [ -z "$password" ]; then
            echo "useQBittorrent: passwordFile is empty: $password_file" >&2
            exit 1
          fi

          ${pkgs.gnused}/bin/sed -i '/^Preferences\\\\WebUI\\\\Password_PBKDF2=/d' "$config_path"
          printf '%s=%s\n' 'Preferences\\WebUI\\Password_PBKDF2' "$password" >> "$config_path"

          ${pkgs.coreutils}/bin/chown ${username}:${primaryGroup} "$config_path"
          ${pkgs.coreutils}/bin/chmod 0600 "$config_path"
        '';

        serviceConfig.PermissionsStartOnly = true;
      })
    ];

    systemd.tmpfiles.settings.qbittorrent-downloads =
      {
        "${effectiveDownloadDir}".d = {
          mode = "0755";
          user = username;
          group = primaryGroup;
        };
      }
      // lib.optionalAttrs (incompleteDir != null) {
        "${incompleteDir}".d = {
          mode = "0755";
          user = username;
          group = primaryGroup;
        };
      };
  }

  (lib.mkIf (path != null) {
    environment.persistence.${path}.directories = [ profileDir ];
  })
]
