{ mode ? "1920x1080", sunshineName ? "headless-sunshine", openFirewall ? false, enableAudio ? true }:
{ config, lib, pkgs, username, ... }:
let
  modeDefinitions = {
    "1280x720" = {
      resolution = {
        x = 1280;
        y = 720;
      };
      modeline = ''Modeline "1280x720" 59.42 1280 1312 1536 1568 720 735 741 757'';
    };
    "1600x900" = {
      resolution = {
        x = 1600;
        y = 900;
      };
      modeline = ''Modeline "1600x900" 33.92 1600 1632 1760 1792 900 921 924 946'';
    };
    "1920x1080" = {
      resolution = {
        x = 1920;
        y = 1080;
      };
      modeline = ''Modeline "1920x1080" 23.53 1920 1952 2040 2072 1080 1106 1108 1135'';
    };
    "2560x1440" = {
      resolution = {
        x = 2560;
        y = 1440;
      };
      modeline = ''Modeline "2560x1440" 42.12 2560 2592 2752 2784 1440 1475 1478 1513'';
    };
    "3840x2160" = {
      resolution = {
        x = 3840;
        y = 2160;
      };
      modeline = ''Modeline "3840x2160" 104.25 3840 3944 4320 4800 2160 2163 2168 2175'';
    };
  };

  selectedMode = lib.attrByPath [ mode ] modeDefinitions."1920x1080" modeDefinitions;
  sunshinePackage = pkgs.sunshine.override {
    boost =
      if pkgs ? boost187 then
        pkgs.boost187
      else
        pkgs.boost;
  };

  launchKitty = pkgs.writeShellScript "launch-headless-kitty" ''
    if [ -x /run/current-system/sw/bin/kitty ]; then
      exec /run/current-system/sw/bin/kitty
    fi

    printf '%s\n' 'kitty is not installed in the active system generation' >&2
    exit 1
  '';

  tinywmHotkeys = pkgs.writeText "headless-sunshine-sxhkdrc" ''
    super + Return
      ${launchKitty}

    ctrl + alt + Return
      ${launchKitty}
  '';

  sunshineApps = [
    {
      name = "Desktop";
      "image-path" = "desktop.png";
    }
  ] ++ lib.optionals config.programs.steam.enable [
    {
      name = "Steam Big Picture";
      "image-path" = "steam.png";
      detached = [
        "/run/current-system/sw/bin/setsid /run/current-system/sw/bin/steam steam://open/bigpicture"
      ];
      "prep-cmd" = [
        {
          do = "";
          undo = "/run/current-system/sw/bin/setsid /run/current-system/sw/bin/steam steam://close/bigpicture";
        }
      ];
    }
  ];
in
{
  imports = lib.optionals enableAudio [
    ((import ../pipewire).usePipewire {})
    ((import ../rtkit) {})
  ];

  assertions = [
    {
      assertion = builtins.hasAttr mode modeDefinitions;
      message =
        "useHeadlessSunshine: unsupported mode `${mode}`. Supported modes: "
        + lib.concatStringsSep ", " (builtins.attrNames modeDefinitions);
    }
  ];

  services.xserver = {
    enable = true;
    videoDrivers = [ "dummy" ];
    resolutions = [ selectedMode.resolution ];
    virtualScreen = selectedMode.resolution;
    defaultDepth = 24;

    deviceSection = ''
      VideoRam 262144
    '';

    monitorSection = ''
      HorizSync 1.0 - 2000.0
      VertRefresh 1.0 - 200.0
      ${selectedMode.modeline}
    '';

    serverFlagsSection = ''
      Option "BlankTime" "0"
      Option "StandbyTime" "0"
      Option "SuspendTime" "0"
      Option "OffTime" "0"
    '';

    desktopManager.runXdgAutostartIfNone = true;

    displayManager.lightdm = {
      enable = true;
      greeter.enable = false;
    };

    displayManager.sessionCommands = lib.mkAfter ''
      ${pkgs.xset}/bin/xset s off
      ${pkgs.xset}/bin/xset -dpms
      ${pkgs.xset}/bin/xset s noblank
      SXHKD_SHELL=${pkgs.runtimeShell} ${pkgs.sxhkd}/bin/sxhkd -c ${tinywmHotkeys} &
    '';

    windowManager.tinywm.enable = true;
  };

  services.displayManager = {
    defaultSession = "none+tinywm";
    autoLogin = {
      enable = true;
      user = username;
    };
  };

  services.sunshine = {
    enable = true;
    package = sunshinePackage;
    inherit openFirewall;
    applications = {
      env = {
        PATH = "/run/current-system/sw/bin:$(HOME)/.local/bin";
      };
      apps = sunshineApps;
    };
    settings = {
      sunshine_name = sunshineName;
      capture = "x11";
      encoder = "software";
      output_name = 0;
    };
  };
}
