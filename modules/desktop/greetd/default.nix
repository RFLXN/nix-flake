{
  enableRegreet ? false,
  regreetCompositor ? "hyprland",
  regreetPrimaryMonitor ? null,
  enableAutoLogin ? false,
  autoLoginSession ? "uwsm-hyprland",
  enableSilentSession ? enableAutoLogin,
}:
{ pkgs, lib, username, ... }:
let
  regreetPkg = pkgs.regreet;
  toLua = lib.generators.toLua { };
  clearTerminal = lib.optionalString enableSilentSession ''
    printf '\033[2J\033[3J\033[H'
  '';
  journalRedirect = lib.optionalString enableSilentSession ''
    exec > >(${lib.getExe' pkgs.systemd "systemd-cat"} --identifier=greetd-session --priority=info)
    exec 2> >(${lib.getExe' pkgs.systemd "systemd-cat"} --identifier=greetd-session --priority=warning)
  '';
  sessionCommand = name: command: pkgs.writeShellScript name ''
    ${clearTerminal}
    ${journalRedirect}
    ${command}
  '';
  hyprlandSessionCommand = sessionCommand "greetd-hyprland-session" ''
    if [ -x /run/current-system/sw/bin/start-hyprland ]; then
      exec /run/current-system/sw/bin/start-hyprland
    else
      exec /run/current-system/sw/bin/Hyprland
    fi
  '';
  uwsmHyprlandSessionCommand = sessionCommand "greetd-uwsm-hyprland-session" ''
    entry=/run/current-system/sw/bin/start-hyprland
    if [ ! -x "$entry" ]; then
      entry=/run/current-system/sw/bin/Hyprland
    fi
    exec ${lib.getExe pkgs.uwsm} start -F -- "$entry"
  '';
  resolvedAutoLoginCommand = {
    "uwsm-hyprland" = uwsmHyprlandSessionCommand;
    "hyprland" = hyprlandSessionCommand;
  }.${autoLoginSession} or autoLoginSession;

  regreetSessionCommand =
    if regreetCompositor == "hyprland" then "Hyprland -c /etc/greetd/hyprland.lua"
    else if regreetCompositor == "cage" then "${lib.getExe pkgs.cage} -s -- ${lib.getExe regreetPkg}"
    else regreetCompositor;

  autoLoginSessionConfig = {
    command = resolvedAutoLoginCommand;
    user = username;
  };

  regreetExitCommand = "${lib.getExe regreetPkg}; hyprctl dispatch 'hl.dsp.exit()'";
  greeterHyprlandConfig = ''
    ${lib.optionalString (regreetPrimaryMonitor != null) ''
      hl.monitor(${toLua {
        output = regreetPrimaryMonitor.name;
        mode = regreetPrimaryMonitor.res;
        position = "0x0";
        scale = 1;
      }})
      hl.monitor(${toLua {
        output = "";
        disabled = true;
      }})
    ''}

    hl.config({
      misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
      },
    })

    hl.on("hyprland.start", function()
      hl.exec_cmd(${toLua regreetExitCommand})
    end)
  '';
in {
  assertions = [
    {
      assertion = enableRegreet || enableAutoLogin;
      message = "useGreetd requires enableRegreet=true or enableAutoLogin=true.";
    }
  ];

  environment.etc = lib.mkMerge [
    (lib.mkIf (enableRegreet && regreetCompositor == "hyprland") {
      "greetd/hyprland.lua".text = greeterHyprlandConfig;
    })
    (lib.mkIf enableRegreet {
      "greetd/regreet.toml".text = ''
        [commands]
        reboot = ["systemctl", "reboot"]
        poweroff = ["systemctl", "poweroff"]
      '';
    })
  ];

  services.greetd = {
    enable = true;
    # NixOS turns this off when initial_session is set, because a restarted
    # greetd logs in again. That is exactly what autologin wants here.
    restart = lib.mkIf enableAutoLogin true;
    settings = {
      # With autologin there is no greeter on purpose: the session logs
      # straight back in after logout and the desktop shell's own lock screen
      # (for example DMS with lockAtStartup) acts as the login prompt.
      default_session = if enableAutoLogin then autoLoginSessionConfig else {
        command = regreetSessionCommand;
        user = "greeter";
      };
    }
    # greetd gives default_session the logind class "greeter", which cannot be
    # locked (loginctl lock-session, lid switch, shell lock integration). The
    # first login after boot therefore runs as initial_session, which is a
    # regular user session. A re-login after logout goes through
    # default_session and is a greeter-class session again.
    // lib.optionalAttrs enableAutoLogin {
      initial_session = autoLoginSessionConfig;
    };
  };

  environment.systemPackages = lib.optionals enableRegreet [ regreetPkg ];
}
