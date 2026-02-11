{ config, lib, pkgs, username, shared, modules, ... }: {
  imports = (with modules.services; [
    (useDocker {
      isBtrfs = true;
      containersAsService = {
        ddns = {
          image = "oznu/cloudflare-ddns";
          environment = {
            ZONE = "rflxn-with-doujin-music.work";
            SUBDOMAIN = "home";
            PROXIED = "false";
          };
          environmentFiles = [ "/persist/secrets/ddns.env" ];
          extraOptions = [ "--network=host" ];
        };
      };
    })
    (useHomeManager { backupCommand = "${pkgs.trash-cli}/bin/trash"; })
    (useJetbrainsRemote { ides = with pkgs.jetbrains; [ webstorm idea ]; })
    (useSsh { allowPasswordLogin = true; })
    (useSyncthing {
      serviceLevel = "system";
      devices = { inherit (shared.syncthing-devices) rflxn-desktop rflxn-asahi; };
      folders = {
        "development" = {
          id = "development";
          path = "/home/${username}/development";
          devices = [ "rflxn-asahi" "rflxn-desktop" ];
        };
        "data" = {
          id = "data";
          path = "/home/${username}/data";
          devices = [ "rflxn-desktop" ];
        };
      };
    })
    (useTailscale {})
    (useVscodeServer {})

  ]) ++ (with modules.programs; [
    (shell.useShell {})
    (shell.useZsh {})
    (useClaudeCode {})
    (useCommonTools {})
    (useDirenv {})
    (useGit { name = "RFLXN"; email = "solid2113@naver.com"; })
    (useNixIndex {})

  ]) ++ (with modules.system; [
    (boot.useEfiBoot { canTouchEfiVariables = true; })
    (boot.useSystemdBoot {})
    (nix.useExperimentalFeatures {})
    (nix.useGc { dates = "Wed 05:00"; })
    (nix.useOptimise { dates = [ "Wed 05:00" ]; })
    (nix.useUnfreePackage {})
    (useImpermanence { rootUuid = "e5d418a8-3c68-48ff-aecd-e94874b879c8"; })
    (useMe { hashedPasswordFile = "/persist/secrets/rflxn.hashedPassword"; })

  ]) ++ [
    ./hardware-configuration.nix
  ];

  # Host-specific configuration
  networking.hostName = "rflxn-server";
  networking.useDHCP = true;

  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];

  # IP forwarding for Docker
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.firewall.enable = false;

  time.timeZone = shared.timezone;
  i18n.defaultLocale = shared.locale;

  system.stateVersion = "25.11";
}
