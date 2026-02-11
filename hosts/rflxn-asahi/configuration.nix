{ config, lib, pkgs, shared, modules, ... }: {
  imports =
    # Desktop
    (with modules.desktop; [
      (plasma6.usePlasma6 { excludePackages = with pkgs.kdePackages; [ kate konsole okular ]; })
      (plasma6.theme.useLeaf {})
      (plasma6.kwin.useBlur {})
      (plasma6.shortcuts.useKitty { key = "Meta+R"; })
      (useSddm { enableHidpi = true; })
    ]) ++

    # Services
    (with modules.services; [
      (pipewire.usePipewire {})
      (useRtkit {})
      (useLibinput {})
      (useHomeManager {})
      (useDocker { isBtrfs = true; isRootless = true; })
      (useTailscale {})
      (useSyncthing { serviceLevel = "user"; })
      (useKeyd { settings = import ./keyd-configs.nix; })
    ]) ++

    # Programs
    (with modules.programs; [
      (shell.useShell {})
      (shell.useZsh {})
      (useFirefox {})
      (useVscode {})
      (useClaudeCode {})
      (useKitty {})
      (useGit { name = "RFLXN"; email = "solid2113@naver.com"; })
      (useFastfetch {
        beforeModules = [
          { type = "custom"; format = "RFLXN's Asahi Linux Macbook"; outputColor = "light_green"; }
          { type = "custom"; format = "https://github.com/RFLXN/nix-flake"; outputColor = "dim_white"; }
        ];
      })
      (useDiscord {})
      (useSpotify {})
      (useNixIndex {})
      (useDirenv {})
      (useCommonTools {})
      (jetbrains.useWebstorm { enableZshAlias = true; })
      (jetbrains.useIntellij { enableZshAlias = true; })
      (useHaruna {})
      (useKcalc { enableWindowsAlias = true; })
      (useKolourpaint { enableWindowsAlias = true; })
    ]) ++

    # Hardware
    (with modules.hardware; [
      (useGraphics {})
      (useBluetooth {})
    ]) ++

    # System
    (with modules.system; [
      (boot.useSystemdBoot { consoleMode = "0"; configurationLimit = 15; })
      (boot.useEfiBoot { canTouchEfiVariables = false; })
      (useImpermanence { rootUuid = "4493ff63-f4f8-48af-b74b-df4434b45fff"; })
      (nix.useUnfreePackage {})
      (nix.useExperimentalFeatures {})
      (nix.useGc { dates = "Wed 05:00"; })
      (nix.useOptimise { dates = [ "Wed 05:00" ]; })
      (useNetworkManager { useWifi = true; })
      (useZram {})
      (useMe { hashedPasswordFile = "/persist/secrets/rflxn.hashedPassword"; })
      (useFcitx5 {})
      (useCjkFonts {})
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
