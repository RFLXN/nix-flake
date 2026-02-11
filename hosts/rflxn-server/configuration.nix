{ config, lib, pkgs, shared, modules, ... }: {
  imports = (with modules.services; [
    (useHomeManager { backupCommand = "${pkgs.trash-cli}/bin/trash"; })
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
    (useSsh { allowPasswordLogin = true; })
    (useSyncthing {
      serviceLevel = "system";
    })
    (useTailscale {})
    (useJetbrainsRemote { ides = with pkgs.jetbrains; [ webstorm idea-ultimate ]; })
    (useVscodeServer {})

  ]) ++ (with modules.programs; [
    (shell.useShell {})
    (shell.useZsh {})
    (useClaudeCode {})
    (useGit { name = "RFLXN"; email = "solid2113@naver.com"; })
    (useNixIndex {})
    (useDirenv {})
    (useCommonTools {})

  ]) ++ (with modules.system; [
    (boot.useSystemdBoot {})
    (boot.useEfiBoot { canTouchEfiVariables = true; })
    (useImpermanence { rootUuid = "e5d418a8-3c68-48ff-aecd-e94874b879c8"; })
    (nix.useUnfreePackage {})
    (nix.useExperimentalFeatures {})
    (nix.useGc { dates = "Wed 05:00"; })
    (nix.useOptimise { dates = [ "Wed 05:00" ]; })
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
