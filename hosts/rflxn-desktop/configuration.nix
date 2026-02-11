{ config, lib, pkgs, username, shared, modules, ... }: {
  imports = (with modules.desktop; [
    (plasma6.kwin.disableWindowBarrier {})
    (plasma6.kwin.useBlur {})
    (plasma6.shortcuts.useGsrSaveReplay { key = "Alt+F9"; })
    (plasma6.shortcuts.useKitty { key = "Meta+R"; })
    (plasma6.shortcuts.useRestartWallpaper { key = "Meta+\\"; })
    (plasma6.theme.useLeaf {})
    (plasma6.usePlasma6 { excludePackages = with pkgs.kdePackages; [ kate konsole okular ]; enableSddmIntegration = true; })
    (useSddm {})
    (useXdgPortal { enableKdeSupport = true; })

  ]) ++ (with modules.services; [
    (pipewire.useDenoisedMic {})
    (pipewire.useLowLatency {})
    (pipewire.usePipewire {})
    (useDocker { isBtrfs = true; isRootless = true; })
    (useGpuScreenRecorder { window = "DP-3"; })
    (useHomeManager { backupCommand = "${pkgs.trash-cli}/bin/trash"; })
    (useKeyd { settings = import ./keyd-configs.nix; })
    (useLinuxWallpaperengine {
      fps = 60;
      wallpapers = [
        { screen = "DP-3"; wallpaper = "2798192282"; }
        { screen = "HDMI-A-1"; wallpaper = "2897249674"; }
      ];
    })
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
        "data" = {
          id = "data";
          path = "/mnt/shared/Data";
          devices = [ "rflxn-server" ];
        };
      };
    })
    (useTailscale {})

  ]) ++ (with modules.programs; [
    (gaming.useLsfgVk {})
    (gaming.useR2modman {})
    (gaming.useSteam {})
    (gaming.useWine { isWayland = true; })
    (jetbrains.useIntellij { enableZshAlias = true; })
    (jetbrains.useWebstorm { enableZshAlias = true; })
    (shell.useShell {})
    (shell.useZsh {})
    (useAyugram {})
    (useClaudeCode {})
    (useCommonTools {})
    (useDirenv {})
    (useDiscord {})
    (useFastfetch {
      beforeModules = [
        { type = "custom"; format = "RFLXN's Desktop"; outputColor = "light_green"; }
        { type = "custom"; format = "https://github.com/RFLXN/nix-flake"; outputColor = "dim_white"; }
      ];
    })
    (useFirefox {})
    (useGit { name = "RFLXN"; email = "solid2113@naver.com"; })
    (useHaruna {})
    (useKcalc { enableWindowsAlias = true; })
    (useKitty {})
    (useKolourpaint { enableWindowsAlias = true; })
    (useLact {})
    (useNixIndex {})
    (useSpotify {})
    (useVscode {})
    (useWaylandUtils {})

  ]) ++ (with modules.hardware; [
    (useAmdGpu { enableOverdrive = true; })
    (useBluetooth {})

  ]) ++ (with modules.system; [
    (boot.useEfiBoot { canTouchEfiVariables = true; })
    (boot.useLanzaboote {})
    (boot.usePlymouth {})
    (boot.useSystemdBoot { configurationLimit = 10; })
    (nix.useExperimentalFeatures {})
    (nix.useGc { dates = "Wed 05:00"; })
    (nix.useOptimise { dates = [ "Wed 05:00" ]; })
    (nix.useUnfreePackage {})
    (useCjkFonts {})
    (useFcitx5 {})
    (useImpermanence { rootUuid = "78b6199d-0161-42e2-9dbd-34c69d72d54e"; })
    (useMe { hashedPasswordFile = "/persist/secrets/rflxn.hashedPassword"; })
    (useNetworkManager {})
    (useZram {})

  ]) ++ [
      ./hardware-configuration.nix
  ];

  # Host-specific configuration
  networking.hostName = "rflxn-desktop";

  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "8.8.8.8"
    "8.8.4.4"
  ];

  time.timeZone = shared.timezone;
  i18n.defaultLocale = shared.locale;

  networking.firewall.enable = false;

  system.copySystemConfiguration = false;
  system.stateVersion = "25.11";
}
