{
  enableRegreet ? false,
  regreetCompositor ? "hyprland",
  regreetPrimaryMonitor ? null,
  enableAutoLogin ? false,
  autoLoginSession ? "uwsm-hyprland",
}:
{ pkgs, lib, username, ... }:
let
  regreetPkg = pkgs.regreet;
  resolvedAutoLoginCommand = {
    "uwsm-hyprland" = "${lib.getExe pkgs.uwsm} start -F -- /run/current-system/sw/bin/start-hyprland";
    "hyprland" = "/run/current-system/sw/bin/start-hyprland";
  }.${autoLoginSession} or autoLoginSession;

  regreetSessionCommand =
    if regreetCompositor == "hyprland" then "Hyprland -c /etc/greetd/hyprland.conf"
    else if regreetCompositor == "cage" then "${lib.getExe pkgs.cage} -s -- ${lib.getExe regreetPkg}"
    else regreetCompositor;

  greeterHyprlandConfig = ''
    ${lib.optionalString (regreetPrimaryMonitor != null) "monitor = ${regreetPrimaryMonitor.name}, ${regreetPrimaryMonitor.res}, 0x0, 1"}
    ${lib.optionalString (regreetPrimaryMonitor != null) "monitor = , disable"}

    misc {
      force_default_wallpaper = 0
      disable_hyprland_logo = true
    }

    exec-once = ${lib.getExe regreetPkg}; hyprctl dispatch exit
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
      "greetd/hyprland.conf".text = greeterHyprlandConfig;
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

  environment.systemPackages = lib.optionals enableRegreet [ regreetPkg ];
}
