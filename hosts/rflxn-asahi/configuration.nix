{ config, lib, pkgs, username, shared, modules, ... }: {
  imports =
    # Desktop
    (with modules.desktop; [
      (plasma6.kwin.useBlur {})
      (plasma6.shortcuts.useKitty { key = "Meta+R"; })
      (plasma6.theme.useLeaf {})
      (plasma6.usePlasma6 { excludePackages = with pkgs.kdePackages; [ kate konsole okular ]; })
      (useSddm { enableHidpi = true; })
    ]) ++

    # Services
    (with modules.services; [
      (pipewire.usePipewire {})
      (useDocker { isBtrfs = true; isRootless = true; })
      (useHomeManager {})
      (useKeyd { settings = import ./keyd-configs.nix; })
      (useLibinput {})
      (useRtkit {})
      (useSyncthing {
        serviceLevel = "user";
        devices = { inherit (shared.syncthing-devices) rflxn-server; };
        folders = {
          "development" = {
            id = "development";
            path = "/home/${username}/development";
            devices = [ "rflxn-server" ];
          };
        };
      })
      (useTailscale {})
    ]) ++

    # Programs
    (with modules.programs; [
      (jetbrains.useIntellij { enableZshAlias = true; })
      (jetbrains.useWebstorm { enableZshAlias = true; })
      (shell.useShell {})
      (shell.useZsh {})
      (useClaudeCode {})
      (useCommonTools {})
      (useDirenv {})
      (useDiscord {})
      (useFastfetch {
        beforeModules = [
          { type = "custom"; format = "RFLXN's Asahi Linux Macbook"; outputColor = "light_green"; }
          { type = "custom"; format = "https://github.com/RFLXN/nix-flake"; outputColor = "dim_white"; }
        ];
      })
      (useFirefox {})
      (useGit { name = "RFLXN"; email = "solid2113@naver.com"; })
      (useHaruna {})
      (useKcalc { enableWindowsAlias = true; })
      (useKitty {})
      (useKolourpaint { enableWindowsAlias = true; })
      (useNixIndex {})
      (useSpotify {})
      (useVscode {})
    ]) ++

    # Hardware
    (with modules.hardware; [
      (useBluetooth {})
      (useGraphics {})
    ]) ++

    # System
    (with modules.system; [
      (boot.useEfiBoot { canTouchEfiVariables = false; })
      (boot.useSystemdBoot { consoleMode = "0"; configurationLimit = 15; })
      (nix.useExperimentalFeatures {})
      (nix.useGc { dates = "Wed 05:00"; })
      (nix.useOptimise { dates = [ "Wed 05:00" ]; })
      (nix.useUnfreePackage {})
      (useCjkFonts {})
      (useFcitx5 {})
      (useImpermanence { rootUuid = "4493ff63-f4f8-48af-b74b-df4434b45fff"; })
      (useMe { hashedPasswordFile = "/persist/secrets/rflxn.hashedPassword"; })
      (useNetworkManager { useWifi = true; })
      (useZram {})
    ]) ++

    # Host-specific
    [
      ./hardware-configuration.nix
    ];

  # Host-specific configuration
  networking.hostName = "rflxn-asahi";

  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "8.8.8.8"
    "8.8.4.4"
  ];

  time.timeZone = shared.timezone;
  i18n.defaultLocale = shared.locale;

  # Asahi firmware (gitignored - provide your own)
  hardware.asahi.peripheralFirmwareDirectory =
    let path = ./firmware;
    in if builtins.pathExists path
      then path
      else throw "Asahi firmware not found at hosts/rflxn-asahi/firmware/. Extract your firmware there.";

  networking.firewall.enable = false;

  system.copySystemConfiguration = false;
  system.stateVersion = "25.11";
}
