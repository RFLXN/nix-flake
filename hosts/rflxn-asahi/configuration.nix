{ config, lib, pkgs, username, shared, modules, ... }: {
  imports =
    # Desktop
    (with modules.desktop; [
      (hyprland.useHyprland {
        followMouse = 0;
        pointerSpeed = -0.25;
        enableMouseAcceleration = false;
        monitors = [
          "eDP-1, 3456x2160@60, 0x0, 1.6"
        ];
        workspaces = [
          "1, monitor:eDP-1, default:true, persistent:true"
          "2, monitor:eDP-1, persistent:true"
          "3, monitor:eDP-1, persistent:true"
          "4, monitor:eDP-1, persistent:true"
          "5, monitor:eDP-1, persistent:true"
        ];
      })
      (hyprland.useDarkMode { qtUseGtkPlatformTheme = false; })
      (gtk.theme.useRosePine {
        variant = "main";
        windowOpacity = 0.6;
      })
      (qt.theme.useRosePine {
        variant = "main";
        accent = "rose";
        kvantumReduceWindowOpacity = 40;
      })
      (hyprland.cursors.useRosePineCursor {})
      (hyprland.windowRules.useDefaults {})
      (hyprland.touchpad.useDefaults {})
      (hyprland.touchpad.gestures.useWorkspaces {})
      (hyprland.useHyprlock {})
      (hyprland.useHypridle {})
      (logind.useLogind {})
      (hyprland.keybinds.useDefaults {})
      (hyprland.keybinds.useKitty {})
      (hyprland.keybinds.useAgsLauncher {})
      (hyprland.keybinds.useAgsRestart { key = "SUPER, backslash"; })
      (hyprland.keybinds.usePrintscreen {})
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
      (hyprland.useHyprshell {})
      (hyprland.useAgs {})
      (hyprland.useTrayBridge {})
      (hyprland.useHyprpolkit {})
      (hyprland.useHyprbars {})
      (useGreetd {
        enableAutoLogin = true;
        autoLoginSession = "uwsm-hyprland";
      })
      (useXdgPortal { enableHyprlandSupport = true; })
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
      (useFirefox { enableWidevine = true; })
      (useGit { name = "RFLXN"; email = "solid2113@naver.com"; })
      (useHaruna {})
      (useKcalc { enableWindowsAlias = true; })
      (useKitty {})
      (useKolourpaint { enableWindowsAlias = true; })
      (useNixIndex {})
      (useSpotify {})
      (useVscode {})
      (useCodex {})
    ]) ++

    # Hardware
    (with modules.hardware; [
      (useBluetooth {})
      (useGraphics { enable32Bit = false; })
    ]) ++

    # System
    (with modules.system; [
      (boot.useEfiBoot { canTouchEfiVariables = false; })
      (boot.useSystemdBoot { consoleMode = "0"; configurationLimit = 15; })
      (nix.useExperimentalFeatures {})
      (nix.useGc { dates = "Wed 05:00"; })
      (nix.useOptimise { dates = [ "Wed 05:00" ]; })
      (nix.useUnfreePackage {})
      (nix.useCache {})
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

  # Apple keyboard: F1-F12 as function keys by default, Fn+F1-F12 for media
  # Note: Asahi Linux inverts the meaning, so fnmode=2 gives us function keys by default
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';

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
