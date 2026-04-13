{ modules, username, ... }: {
  imports = with modules.desktop; [
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
    (hyprland.keybinds.useScreenOff { key = "CTRL SHIFT, P"; })
    (hyprland.useAgs {})
    (hyprland.useDarkMode { qtUseGtkPlatformTheme = false; })
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
    (hyprland.useQuickShell {})
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
    (defaultApps.useDefaultApps {})
    (defaultApps.useFirefox {})
    (defaultApps.useHaruna {})
    (defaultApps.useKitty {})
    (defaultApps.useLibreOffice {})
    (defaultApps.usePeaZip {})
    (defaultApps.useVscode {})
    (useXdgPortal { enableHyprlandSupport = true; })
  ];
}
