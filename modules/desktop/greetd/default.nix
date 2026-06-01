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
  toLua = lib.generators.toLua {};
  clearTerminal = lib.optionalString enableSilentSession ''
    printf '\033[2J\033[3J\033[H'
  '';
  journalRedirect = lib.optionalString enableSilentSession ''
    exec > >(${lib.getExe' pkgs.systemd "systemd-cat"} --identifier=greetd-session --priority=info)
    exec 2> >(${lib.getExe' pkgs.systemd "systemd-cat"} --identifier=greetd-session --priority=warning)
  '';
  sessionCommand = command: "${lib.getExe pkgs.bash} -lc ${lib.escapeShellArg ''
    ${clearTerminal}
    ${journalRedirect}
    ${command}
  ''}";
  hyprlandSessionCommand = sessionCommand ''
    if [ -x /run/current-system/sw/bin/start-hyprland ]; then
      exec /run/current-system/sw/bin/start-hyprland
    else
      exec /run/current-system/sw/bin/Hyprland
    fi
  '';
  uwsmHyprlandSessionCommand = sessionCommand ''
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
    settings = {
      default_session = if enableAutoLogin then {
        command = resolvedAutoLoginCommand;
        user = username;
      } else {
        command = regreetSessionCommand;
        user = "greeter";
      };
    };
  };

  systemd.services.greetd.serviceConfig = lib.mkIf enableSilentSession {
    StandardOutput = "journal";
    StandardError = "journal";
  };

  environment.systemPackages = lib.optionals enableRegreet [ regreetPkg ];
}
