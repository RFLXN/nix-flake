{ config, pkgs, username, ... }: {
  systemd.user.services.gpu-screen-recorder = {
    description = "GPU Screen Recorder (Replay Mode)";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.gpu-screen-recorder}/bin/gpu-screen-recorder -w \"DP-3\" -f 60 -a default_output -c mp4 -r 300 -q high -o /home/${username}/Videos/replays";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  # Add polkit rule to allow gpu-screen-recorder without authentication
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.policykit.exec" &&
          action.lookup("program").indexOf("gpu-screen-recorder") > -1 &&
          subject.user == "${username}") {
        return polkit.Result.YES;
      }
    });
  '';

  # Create a script to save the replay
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "gsr-save-replay" ''
      ${pkgs.killall}/bin/killall -SIGUSR1 gpu-screen-recorder
    '')
  ];
}
