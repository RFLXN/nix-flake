{ config, lib, pkgs, username, shared, modules, ... }: {
  imports = (with modules.desktop; [
    (gtk.theme.usePapirusIcon {})
    (gtk.theme.useRosePine {
      variant = "main";
      windowOpacity = 0.6;
    })
    (hyprland.appearance {
      borderSize = 1;
      activeBorderColor = "rgb(888888)";
      inactiveBorderColor = "rgb(444444)";
      activeOpacity = 0.95;
      inactiveOpacity = 0.85;
      fullscreenOpacity = 1.0;
      blurSize = 10;
      blurPasses = 3;
    })
    (hyprland.cursors.useRosePineCursor {})
    (hyprland.keybinds.useAgsLauncher {})
    (hyprland.keybinds.useAgsRestart { key = "SUPER, backslash"; })
    (hyprland.keybinds.useDefaults {})
    (hyprland.keybinds.useGsrSaveReplay {})
    (hyprland.keybinds.useHyprshot {})
    (hyprland.keybinds.useKitty {})
    (hyprland.useAgs {})
    (hyprland.useDarkMode { qtUseGtkPlatformTheme = false; })
    (hyprland.useHypridle {
      timeToScreenOff = 1799;
      timeToLock = 1800;
      timeToSuspend = 3600;
    })
    (hyprland.useHyprland {
      followMouse = 0;
      pointerSpeed = -0.25;
      enableMouseAcceleration = false;
      disableHardwareCursors = true;
      monitors = [
        "DP-3, 1920x1080@200, 1080x220, 1"
        "HDMI-A-1, 1920x1080@60, 0x0, 1, transform, 1"
      ];
      workspaces = [
        "1, monitor:DP-3, default:true, persistent:true, layout:master"
        "2, monitor:DP-3, persistent:true, layout:master"
        "3, monitor:DP-3, persistent:true, layout:master"
        "4, monitor:DP-3, persistent:true, layout:master"
        "5, monitor:DP-3, persistent:true, layout:master"
        "6, monitor:HDMI-A-1, default:true, persistent:true, layout:scrolling, layoutopt:direction:down"
      ];
    })
    (hyprland.useHyprlock {})
    (hyprland.useHyprpolkit {})
    (hyprland.useHyprshell {})
    (hyprland.useTrayBridge {})
    (hyprland.wallpaper.useLinuxWallpaperEngine {
      wallpapers = [
        { screen = "DP-3"; wallpaper = "2798192282"; }
        { screen = "HDMI-A-1"; wallpaper = "2897249674"; }
      ];
    })
    (hyprland.windowRules.useDefaults {})
    (hyprland.windowRules.useFixedSpotify { workspace = "6"; })
    (hyprland.windowRules.useFixedVesktop { workspace = "6"; })
    (qt.theme.usePapirusIcon {})
    (qt.theme.useRosePine {
      variant = "main";
      accent = "rose";
      kvantumReduceWindowOpacity = 20;
    })
    /* (hyprland.wallpaper.useHyprpaper {
      wallpaper = "/home/${username}/Pictures/wallpaper.jpg";
      wallpapers = [
        { monitor = "DP-3"; path = "/home/${username}/Pictures/main-wallpaper.jpg"; }
        { monitor = "HDMI-A-1"; path = "/home/${username}/Pictures/sub-wallpaper.jpg"; }
      ];
      monitors = [ "DP-3" "HDMI-A-1" ];
    }) */
    (useGreetd {
      enableAutoLogin = true;
      autoLoginSession = "uwsm-hyprland";
    })
    (useXdgPortal { enableHyprlandSupport = true; })

  ]) ++ (with modules.services; [
    (pipewire.useDenoisedMic {})
    (pipewire.useLowLatency {})
    (pipewire.usePipewire {})
    (useDocker { isBtrfs = true; isRootless = true; })
    (useFlatpak {})
    (useGpuScreenRecorder { window = "DP-3"; })
    (useHomeManager { backupCommand = "${pkgs.trash-cli}/bin/trash"; })
    (useKeyd { settings = import ./keyd-configs.nix; })
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
    (gaming.useProtonplus {})
    (gaming.useR2modman {})
    (gaming.useSteam { enableGamescope = true; })
    (gaming.useWine { isWayland = true; })
    (jetbrains.useIntellij { enableZshAlias = true; })
    (jetbrains.useWebstorm { enableZshAlias = true; })
    (shell.useShell {})
    (shell.useZsh {})
    (useAyugram {})
    (useBlueman {})
    (useClaudeCode {})
    (useCodex {})
    (useCommonTools {})
    (useDirenv {})
    (useDiscord {})
    (useDolphin {})
    (useFastfetch {
      beforeModules = [
        { type = "custom"; format = "RFLXN's Desktop"; outputColor = "light_green"; }
        { type = "custom"; format = "https://github.com/RFLXN/nix-flake"; outputColor = "dim_white"; }
      ];
    })
    (useFirefox {})
    (useGit { name = "RFLXN"; email = "solid2113@naver.com"; })
    (useHaruna {})
    (useHyprshot {})
    (useKcalc { enableWindowsAlias = true; })
    (useKitty {})
    (useKolourpaint { enableWindowsAlias = true; })
    (useLact {})
    (useLibreOffice {})
    (useNixIndex {})
    (useNmApplet {})
    (usePwvucontrol {})
    (useSpotify {})
    (useThunar {})
    (useVscode {})
    (useWaylandUtils {})

  ]) ++ (with modules.hardware; [
    (useAmdGpu { enableOverdrive = true; })
    (useBluetooth {})
    (useGraphics {})

  ]) ++ (with modules.system; [
    (boot.useEfiBoot { canTouchEfiVariables = true; })
    (boot.useLanzaboote {})
    (boot.usePlymouth {})
    (boot.useSystemdBoot { configurationLimit = 10; })
    (nix.useCache {})
    (nix.useExperimentalFeatures {})
    (nix.useGc { dates = "Wed 05:00"; })
    (nix.useOptimise { dates = [ "Wed 05:00" ]; })
    (nix.useUnfreePackage {})
    (useCjkFonts {})
    (useFcitx5 {})
    (useImpermanence { rootUuid = "78b6199d-0161-42e2-9dbd-34c69d72d54e"; })
    (useMe { hashedPasswordFile = "/persist/secrets/rflxn.hashedPassword"; })
    (useNetworkManager { useWifi = true; })
    (useZram {})

  ]) ++ [
      ./hardware-configuration.nix
  ];

  # Host-specific configuration
  networking.hostName = "rflxn-desktop";

  networking.nameservers = [
    "1.0.0.1"
    "1.1.1.1"
    "8.8.4.4"
    "8.8.8.8"
  ];

  time.timeZone = shared.timezone;
  i18n.defaultLocale = shared.locale;

  networking.firewall.enable = false;

  system.copySystemConfiguration = false;
  system.stateVersion = "25.11";
}
