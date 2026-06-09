{ config, lib, pkgs, username, shared, modules, ... }:
let
  asahiRenderNode = "/dev/dri/by-path/platform-406400000.gpu-render";

  aquamarineForceRenderNodePatch = builtins.toFile "aquamarine-force-render-node.patch" ''
    diff --git a/src/backend/Session.cpp b/src/backend/Session.cpp
    index 5b159cf..84ed8b8 100644
    --- a/src/backend/Session.cpp
    +++ b/src/backend/Session.cpp
    @@ -1,4 +1,5 @@
     #include <aquamarine/backend/Backend.hpp>
    +#include <cstdlib>
     #include <fcntl.h>
     
     extern "C" {
    @@ -164,6 +165,20 @@ bool Aquamarine::CSessionDevice::supportsKMS() {
     }
     
     void Aquamarine::CSessionDevice::resolveMatchingRenderNode(udev_device* cardDevice) {
    +    const char* forcedRenderNode = std::getenv("AQ_RENDER_NODE");
    +    if (forcedRenderNode && forcedRenderNode[0] != '\0') {
    +        renderNodeFd = open(forcedRenderNode, O_RDWR | O_CLOEXEC);
    +        if (renderNodeFd >= 0) {
    +            session->backend->log(AQ_LOG_DEBUG, std::format("drm: Using forced render node {}", forcedRenderNode));
    +            return;
    +        }
    +
    +        session->backend->log(AQ_LOG_WARNING,
    +                              std::format("drm: Failed to open forced render node {}, falling back to udev matching",
    +                                          forcedRenderNode));
    +        renderNodeFd = -1;
    +    }
    +
         if (!cardDevice)
             return;
     
  '';

  aquamarineWithForcedRenderNode = pkgs.aquamarine.overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      aquamarineForceRenderNodePatch
    ];
  });

  hyprlandWithForcedRenderNode = pkgs.symlinkJoin {
    name = "${pkgs.hyprland.name}-asahi-render-node";
    version = pkgs.hyprland.version;
    paths = [ pkgs.hyprland ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    passthru = (pkgs.hyprland.passthru or {}) // {
      override = _: hyprlandWithForcedRenderNode;
    };
    meta = (pkgs.hyprland.meta or {}) // {
      outputsToInstall = [ "out" ];
    };

    postBuild = ''
      wrapProgram "$out/bin/Hyprland" \
        --set AQ_RENDER_NODE ${asahiRenderNode} \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ aquamarineWithForcedRenderNode ]}
      wrapProgram "$out/bin/start-hyprland" \
        --set AQ_RENDER_NODE ${asahiRenderNode} \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ aquamarineWithForcedRenderNode ]}
    '';
  };

  xdgDesktopPortalHyprlandCached = pkgs.xdg-desktop-portal-hyprland // {
    override = _: xdgDesktopPortalHyprlandCached;
  };
in {
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
      (hyprland.keybinds.useAgsLauncher {})
      (hyprland.keybinds.useAgsRestart { key = "SUPER, backslash"; })
      (hyprland.keybinds.useDefaults {})
      (hyprland.keybinds.useKitty {})
      (hyprland.keybinds.useMediaFunctions {})
      (hyprland.keybinds.useToggleMonitorSetup {
        settings = [
          {
            monitorName = "eDP-1";
            defaultSetup = "eDP-1, 3456x2160@60, 0x0, 1.6";
            toggleSetup = "eDP-1, 3456x2160@120, 0x0, 1.6";
            key = "SUPER SHIFT, P";
          }
        ];
      })
      (hyprland.touchpad.gestures.useWorkspaces {})
      (hyprland.touchpad.useDefaults {})
      (hyprland.useAgs {
        systemControlMenu = {
          volume.program = pkgs.pwvucontrol;
          bluetooth.program = pkgs.blueman;
        };
      notificationPopups = {
        monitor = "eDP-1";
        position = "bottom-left";
        timeoutMs = 5000;
        maxVisible = 3;
      };
        layout = {
          layouts = [
            {
              monitor = "eDP-1";
              widgets = {
                left = [ "feed-hub" "window-title" ];
                center = [ "workspaces" "datetime" ];
                right = [ "system-controls" ];
              };
              components = [
                "app-launcher-menu"
                "feed-hub-menu"
                "system-controls-menu"
                "shutdown-confirmation-overlay"
                "global-menu-close-layer"
                "system-controls-volume-osd"
              ];
            }
          ];
        };
      })
      (hyprland.useDarkMode { qtUseGtkPlatformTheme = false; })
      (hyprland.useHypridle {})
      (hyprland.useHyprland {
        followMouse = 0;
        pointerSpeed = -0.25;
        enableMouseAcceleration = false;
        monitors = [
          "eDP-1, 3456x2160@60, 0x0, 1.6"
        ];
        workspaces = [
          "1, monitor:eDP-1, default:true, persistent:true, layout:master"
          "2, monitor:eDP-1, persistent:true, layout:master"
          "3, monitor:eDP-1, persistent:true, layout:master"
          "4, monitor:eDP-1, persistent:true, layout:master"
          "5, monitor:eDP-1, persistent:true, layout:master"
          "6, monitor:eDP-1, persistent:true, layout:master"
          "7, monitor:eDP-1, persistent:true, layout:master"
        ];
      })
      (hyprland.useXdgMenu {})
      (hyprland.useXdgUserDirs {})
      (hyprland.useHyprlock {})
      (hyprland.useHyprpolkit {})
      (hyprland.useHyprshell {})
      (hyprland.useTrayBridge {})
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
      (useTailscale { enableSystemTray = true; })
    ]) ++

    # Programs
    (with modules.programs; [
      (jetbrains.useIntellij { enableZshAlias = true; })
      (jetbrains.useWebstorm { enableZshAlias = true; })
      (shell.useShell {})
      (shell.useZsh {})
      (useBlueman {})
      (useClaudeCode {})
      (useCodex {})
      (useCodexDesktop {})
      (useCommonTools {})
      (useDirenv {})
      (useVesktop {})
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
      (useSpotify {})
      (useThunderbird {})
      (useVscode {})
      (usePeaZip {})
      (usePwvucontrol {})
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
      (boot.useSystemdBoot { consoleMode = "0"; configurationLimit = 15; })
      (nix.useCache {})
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

  programs.hyprland.package = lib.mkForce hyprlandWithForcedRenderNode;
  programs.hyprland.portalPackage = lib.mkForce xdgDesktopPortalHyprlandCached;

  environment.sessionVariables.AQ_RENDER_NODE = asahiRenderNode;
  home-manager.users.${username}.systemd.user.sessionVariables.AQ_RENDER_NODE = asahiRenderNode;

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

  networking.firewall.enable = false;

  system.copySystemConfiguration = false;
  system.stateVersion = "25.11";
}
