{ pkgs, modules, username, ... }: {
  imports = with modules.desktop; [
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
    (hyprland.keybinds.useGsrSaveReplay {})
    (hyprland.keybinds.useHyprshot {})
    (hyprland.keybinds.useKitty {})
    (hyprland.keybinds.useScreenOff { key = "CTRL SHIFT, P"; })
    (hyprland.useAgs {
      systemControlMenu = {
        volume.program = pkgs.pwvucontrol;
        bluetooth.program = pkgs.blueman;
      };
      layout = {
        layouts = [
          {
            monitor = "DP-3";
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
            ];
          }
          {
            monitor = "HDMI-A-1";
            widgets = {
              left = [ "datetime" ];
              center = [ "workspaces" ];
              right = [ "hw-monitor" ];
            };
            components = [];
          }
        ];
      };
    })
    (hyprland.useDarkMode { qtUseGtkPlatformTheme = false; })
    (hyprland.useHyprland {
      followMouse = 0;
      pointerSpeed = -0.25;
      enableMouseAcceleration = false;
      disableHardwareCursors = true;
      monitors = [
        { output = "DP-3"; mode = "1920x1080@200"; position = "1080x220"; scale = 1; }
        { output = "HDMI-A-1"; mode = "1920x1080@60"; position = "0x0"; scale = 1; transform = 1; }
      ];
      workspaces = [
        { workspace = "1"; monitor = "DP-3"; default = true; persistent = true; layout = "master"; }
        { workspace = "2"; monitor = "DP-3"; persistent = true; layout = "master"; }
        { workspace = "3"; monitor = "DP-3"; persistent = true; layout = "master"; }
        { workspace = "4"; monitor = "DP-3"; persistent = true; layout = "master"; }
        { workspace = "5"; monitor = "DP-3"; persistent = true; layout = "master"; }
        { workspace = "6"; monitor = "DP-3"; persistent = true; layout = "master"; }
        { workspace = "7"; monitor = "DP-3"; persistent = true; layout = "master"; }
        { workspace = "8"; monitor = "HDMI-A-1"; default = true; persistent = true; layout = "scrolling"; layout_opts.direction = "down"; }
      ];
    })
    (hyprland.useXdgMenu {})
    (hyprland.useXdgUserDirs {})
    (hyprland.useHyprlock {})
    (hyprland.useHyprpolkit {})
    (hyprland.useHyprshell {})
    (hyprland.wallpaper.useLinuxWallpaperEngine {
      wallpapers = [
        { screen = "DP-3"; wallpaper = "2798192282"; }
        { screen = "HDMI-A-1"; wallpaper = "2897249674"; }
      ];
    })
    (hyprland.windowRules.useDefaults {})
    (hyprland.windowRules.useFixedDiscord { workspace = "8"; })
    (hyprland.windowRules.useFixedMopiMopi { workspace = "8"; })
    (hyprland.windowRules.useFixedSpotify { workspace = "8"; })
    (hyprland.windowRules.useFixedVesktop { workspace = "8"; })
    (qt.theme.usePapirusIcon {})
    (qt.theme.useMatcha {
      kvantumReduceWindowOpacity = 20;
    })
    (qt.useDolphinQtTheme {})
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
    (xdgPortal.useXdgPortal {})
    (xdgPortal.useHyprlandPortal { useQtTheme = true; })
  ];
}
