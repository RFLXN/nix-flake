{
  compositor ? "hyprland",
  primaryMonitor,
}:
{ pkgs, lib, ... }:
let
  regreetPkg = pkgs.regreet;

  greeterHyprlandConfig = ''
    monitor = ${primaryMonitor.name}, ${primaryMonitor.res}, 0x0, 1
    monitor = , disable

    misc {
      force_default_wallpaper = 0
      disable_hyprland_logo = true
    }

    exec-once = ${lib.getExe regreetPkg}; hyprctl dispatch exit
  '';

  sessionCommand = {
    hyprland = "Hyprland -c /etc/greetd/hyprland.conf";
    cage = "${lib.getExe pkgs.cage} -s -- ${lib.getExe regreetPkg}";
  }.${compositor};
in {
  environment.etc."greetd/hyprland.conf".text = greeterHyprlandConfig;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = sessionCommand;
        user = "greeter";
      };
    };
  };

  environment.systemPackages = [ regreetPkg ];

  environment.etc."greetd/regreet.toml".text = ''
    [commands]
    reboot = ["systemctl", "reboot"]
    poweroff = ["systemctl", "poweroff"]
  '';
}
