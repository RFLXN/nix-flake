{ config, pkgs, username, shared, modules, ... }:
let
  dankLinux = import ./dank-linux.nix;
in
{
  imports =
    # Desktop
    (with modules.desktop; [
      (gtk.theme.usePapirusIcon {})
      (gtk.theme.useMatcha {
        windowOpacity = 0.6;
      })
      (hyprland.appearance {
        borderSize = 1;
        rounding = 12;
        activeBorderColor = "rgb(888888)";
        inactiveBorderColor = "rgb(444444)";
        activeOpacity = 0.95;
        inactiveOpacity = 0.85;
        fullscreenOpacity = 1.0;
        blurSize = 10;
        blurPasses = 3;
      })
      (hyprland.cursors.useRosePineCursor {})
      (hyprland.keybinds.useDankLinuxLauncher {})
      (hyprland.keybinds.useDefaults {})
      (hyprland.keybinds.useKitty {})
      (hyprland.keybinds.useMediaFunctions {})
      (hyprland.keybinds.useToggleMonitorSetup {
        settings = [
          {
            monitorName = "eDP-1";
            defaultSetup = { output = "eDP-1"; mode = "3456x2160@60"; position = "0x0"; scale = 1.6; };
            toggleSetup = { output = "eDP-1"; mode = "3456x2160@120"; position = "0x0"; scale = 1.6; };
            key = "SUPER SHIFT, P";
          }
        ];
      })
      (hyprland.touchpad.gestures.useWorkspaces {})
      (hyprland.touchpad.useDefaults {})
      (hyprland.useDankLinux dankLinux)
      (hyprland.useDarkMode { qtUseGtkPlatformTheme = false; })
      (hyprland.useHyprland {
        followMouse = 0;
        pointerSpeed = -0.25;
        enableMouseAcceleration = false;
        monitors = [
          { output = "eDP-1"; mode = "3456x2160@60"; position = "0x0"; scale = 1.6; }
        ];
        workspaces = [
          { workspace = "1"; monitor = "eDP-1"; default = true; persistent = true; layout = "master"; }
          { workspace = "2"; monitor = "eDP-1"; persistent = true; layout = "master"; }
          { workspace = "3"; monitor = "eDP-1"; persistent = true; layout = "master"; }
          { workspace = "4"; monitor = "eDP-1"; persistent = true; layout = "master"; }
          { workspace = "5"; monitor = "eDP-1"; persistent = true; layout = "master"; }
          { workspace = "6"; monitor = "eDP-1"; persistent = true; layout = "master"; }
          { workspace = "7"; monitor = "eDP-1"; persistent = true; layout = "master"; }
        ];
      })
      (hyprland.useXdgMenu {})
      (hyprland.useXdgUserDirs {})
      (hyprland.useHyprpolkit {})
      (hyprland.useHyprshell {})
      (hyprland.windowRules.useDefaults {})
      (logind.useLogind {})
      (qt.theme.usePapirusIcon {})
      (qt.theme.useMatcha {
        kvantumReduceWindowOpacity = 40;
      })
      (qt.useDolphinQtTheme {})
      (useGreetd {
        enableAutoLogin = true;
        autoLoginSession = "uwsm-hyprland";
      })
      (defaultApps.useDefaultApps {})
      (defaultApps.useFirefox {})
      # (defaultApps.useHaruna {})
      (defaultApps.useKitty {})
      (defaultApps.usePeaZip {})
      (defaultApps.useVscode {})
      (xdgPortal.useXdgPortal {})
      (xdgPortal.useHyprlandPortal { useQtTheme = true; })
    ]) ++

    # Services
    (with modules.services; [
      (pipewire.usePipewire {})
      #(useBatteryLogger {
      #  batteryDeviceName = "macsmc-battery";
      #})
      (useDocker { isBtrfs = true; isRootless = true; })
      (useFlatpak {})
      (useHomeManager { backupCommand = "${pkgs.trash-cli}/bin/trash"; })
      (useKeyd { settings = import ./keyd-configs.nix; })
      (useLibinput {})
      (useRemovableStorageAutoMount {})
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
      (useTailscale { openFirewall = true; })
    ]) ++

    # Programs
    (with modules.programs; [
      (jetbrains.useIntellij { enableZshAlias = true; })
      (jetbrains.useWebstorm { enableZshAlias = true; })
      (shell.useShell {})
      (shell.useZsh {})
      (useClaudeCode {})
      (useCodex {})
      (useCodexDesktop { quitOnClose = true; })
      (useCommonTools {})
      (useChromium {})
      (useDirenv {})
      (useEquibop {})
      (useAyugram {})
      (useDolphin { withSilentKdeDeps = true; })
      (useFastfetch {
        beforeModules = [
          { type = "custom"; format = "RFLXN's Asahi Linux Macbook"; outputColor = "light_green"; }
          { type = "custom"; format = "https://github.com/RFLXN/nix-flake"; outputColor = "dim_white"; }
        ];
      })
      (useFirefox { enableWidevine = true; })
      (useGit { name = "RFLXN"; email = "solid2113@naver.com"; })
      (useHaruna {})
      (useKcalc {})
      (useKitty {})
      (useKolourpaint {})
      (useNixIndex {})
      (useObsidian {})
      (useSpotify {})
      (useThunderbird {})
      (useVscode {})
      (usePeaZip {})
      (useWaylandUtils {})
    ]) ++

    # Hardware
    (with modules.hardware; [
      (useBluetooth {})
      (useGraphics { enable32Bit = false; })
    ]) ++

    # System
    (with modules.system; [
      (boot.useEfiBoot { canTouchEfiVariables = false; })
      (boot.useSystemdBoot { consoleMode = "0"; configurationLimit = 5; })
      (nix.useCache {})
      (nix.useExperimentalFeatures {})
      (nix.useGc { dates = "Wed 05:00"; })
      (nix.useOptimise { dates = [ "Wed 05:00" ]; })
      (nix.useUnfreePackage {})
      (useCjkFonts {})
      (useFcitx5 {})
      (useFirewall {
        trustedInterfaces = [ config.services.tailscale.interfaceName ];
      })
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

  hardware.asahi.enable = true;

  # Apple keyboard: F1-F12 as function keys by default, Fn+F1-F12 for media
  # Note: Asahi Linux inverts the meaning, so fnmode=2 gives us function keys by default
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';

  networking.nameservers = [
    "1.0.0.1"
    "1.1.1.1"
    "8.8.4.4"
    "8.8.8.8"
  ];

  time.timeZone = shared.timezone;
  i18n.defaultLocale = shared.locale;

  # Asahi firmware (gitignored - provide your own)
  hardware.asahi.peripheralFirmwareDirectory =
    let path = ./firmware;
    in if builtins.pathExists path
      then path
      else throw "Asahi firmware not found at hosts/rflxn-asahi/firmware/. Extract your firmware there.";

  system.copySystemConfiguration = false;
  system.stateVersion = "25.11";
}
