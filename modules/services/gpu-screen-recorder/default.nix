{
  window ? "screen",
  framerate ? 60,
  replaySeconds ? 300,
  quality ? "high",
  container ? "mp4",
  audioSource ? "default_output",
  outputDir ? null
}:
{ pkgs, username, ... }: let
  outputPath = if outputDir != null then outputDir else "/home/${username}/Videos/replays";
in {
  systemd.user.services.gpu-screen-recorder = {
    description = "GPU Screen Recorder (Replay Mode)";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.gpu-screen-recorder}/bin/gpu-screen-recorder -w \"${window}\" -f ${toString framerate} -a ${audioSource} -c ${container} -r ${toString replaySeconds} -q ${quality} -o ${outputPath}";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.policykit.exec" &&
          action.lookup("program").indexOf("gpu-screen-recorder") > -1 &&
          subject.user == "${username}") {
        return polkit.Result.YES;
      }
    });
  '';

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "gsr-save-replay" ''
      ${pkgs.killall}/bin/killall -SIGUSR1 gpu-screen-recorder
      ${pkgs.libnotify}/bin/notify-send "GPU Screen Recorder" "Replay saved!" -i media-record
    '')

    (pkgs.makeDesktopItem {
      name = "gsr-save-replay";
      desktopName = "GPU Screen Recorder Save Replay";
      exec = "gsr-save-replay";
      icon = "media-record";
      terminal = false;
      type = "Application";
      categories = [ "Utility" ];
    })
  ];
}
