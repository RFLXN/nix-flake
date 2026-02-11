{ config, lib, pkgs, username, shared, modules, ... }: {
  imports = (with modules.desktop; [
    (plasma6.usePlasma6 { excludePackages = with pkgs.kdePackages; [ kate konsole okular ]; enableSddmIntegration = true; })
    (plasma6.theme.useLeaf {})
    (plasma6.kwin.useBlur {})
    (plasma6.kwin.disableWindowBarrier {})
    (plasma6.shortcuts.useKitty { key = "Meta+R"; })
    (plasma6.shortcuts.useGsrSaveReplay { key = "Alt+F9"; })
    (plasma6.shortcuts.useRestartWallpaper { key = "Meta+\\"; })
    (useXdgPortal { enableKdeSupport = true; })
    (useSddm {})

  ]) ++ (with modules.services; [
    (pipewire.usePipewire {})
    (pipewire.useLowLatency {})
    (pipewire.useDenoisedMic {})
    (useRtkit {})
    (useHomeManager { backupCommand = "${pkgs.trash-cli}/bin/trash"; })
    (useDocker { isBtrfs = true; isRootless = true; })
    (useTailscale {})
    (useSyncthing {
      serviceLevel = "user";
      /* devices = { inherit (shared.syncthing-devices) rflxn-server; };
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
      }; */
    })
    (useKeyd { settings = import ./keyd-configs.nix; })
    (useGpuScreenRecorder { window = "DP-3"; })
    (useLinuxWallpaperengine {
      fps = 60;
      wallpapers = [
        { screen = "DP-3"; wallpaper = "2798192282"; }
        { screen = "HDMI-A-1"; wallpaper = "2897249674"; }
      ];
    })

  ]) ++ (with modules.programs; [
    (shell.useShell {})
    (shell.useZsh {})
    (useFirefox {})
    (useVscode {})
    (useClaudeCode {})
    (useKitty {})
    (useGit { name = "RFLXN"; email = "solid2113@naver.com"; })
    (useFastfetch {
      beforeModules = [
        { type = "custom"; format = "RFLXN's Desktop"; outputColor = "light_green"; }
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
    (useLact {})
    (gaming.useSteam {})
    (gaming.useR2modman {})
    (gaming.useLsfgVk {})
    (gaming.useWine { isWayland = true; })
    (useWaylandUtils {})
    (useAyugram {})

  ]) ++ (with modules.hardware; [
    (useAmdGpu { enableOverdrive = true; })
    (useBluetooth {})
    
  ]) ++ (with modules.system; [
    (boot.useSystemdBoot { configurationLimit = 10; })
    (boot.useEfiBoot { canTouchEfiVariables = true; })
    (boot.useLanzaboote {})
    (boot.usePlymouth {})
    (useImpermanence { rootUuid = "78b6199d-0161-42e2-9dbd-34c69d72d54e"; })
    (nix.useUnfreePackage {})
    (nix.useExperimentalFeatures {})
    (nix.useGc { dates = "Wed 05:00"; })
    (nix.useOptimise { dates = [ "Wed 05:00" ]; })
    (useNetworkManager {})
    (useZram {})
    (useMe { hashedPasswordFile = "/persist/secrets/rflxn.hashedPassword"; })
    (useFcitx5 {})
    (useCjkFonts {})

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
