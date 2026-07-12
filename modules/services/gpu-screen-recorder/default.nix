{
  window ? "screen",
  framerate ? 60,
  replaySeconds ? 300,
  replayStorage ? "ram",
  restartReplayOnSave ? false,
  bitrateMode ? "cbr",
  bitrate ? 40000,
  quality ? "high",
  container ? "mp4",
  audioSource ? "default_output",
  makeDateFolders ? false,
  postSaveScript ? null,
  outputDir ? null,
}:
{ config, lib, pkgs, username, ... }:
let
  recorder = config.programs.gpu-screen-recorder.package;
  outputPath = if outputDir != null then outputDir else "/home/${username}/Videos/replays";
  yesNo = enabled: if enabled then "yes" else "no";
  qualityValue = if bitrateMode == "cbr" then toString bitrate else quality;

  recorderArgs = [
    "-w"
    window
    "-f"
    (toString framerate)
    "-a"
    audioSource
    "-c"
    container
    "-r"
    (toString replaySeconds)
    "-replay-storage"
    replayStorage
    "-restart-replay-on-save"
    (yesNo restartReplayOnSave)
    "-bm"
    bitrateMode
    "-q"
    qualityValue
    "-df"
    (yesNo makeDateFolders)
    "-o"
    outputPath
  ] ++ lib.optionals (postSaveScript != null) [
    "-sc"
    (toString postSaveScript)
  ];

  saveReplay = pkgs.writeShellScriptBin "gsr-save-replay" ''
    set -euo pipefail

    if ${lib.getExe' pkgs.systemd "systemctl"} --user kill \
      --kill-whom=main \
      --signal=SIGUSR1 \
      gpu-screen-recorder.service; then
      ${lib.getExe pkgs.libnotify} "GPU Screen Recorder" "Replay save requested" -i media-record || true
    else
      ${lib.getExe pkgs.libnotify} "GPU Screen Recorder" "Replay service is not running" -u critical -i media-record || true
      exit 1
    fi
  '';
in
{
  assertions = [
    {
      assertion = lib.isInt framerate && framerate > 0;
      message = "useGpuScreenRecorder: framerate must be a positive integer.";
    }
    {
      assertion = lib.isInt replaySeconds && replaySeconds >= 2 && replaySeconds <= 86400;
      message = "useGpuScreenRecorder: replaySeconds must be between 2 and 86400.";
    }
    {
      assertion = builtins.elem replayStorage [ "ram" "disk" ];
      message = ''useGpuScreenRecorder: replayStorage must be "ram" or "disk".'';
    }
    {
      assertion = builtins.elem bitrateMode [ "auto" "qp" "vbr" "cbr" ];
      message = ''useGpuScreenRecorder: bitrateMode must be "auto", "qp", "vbr", or "cbr".'';
    }
    {
      assertion = lib.isInt bitrate && bitrate > 0;
      message = "useGpuScreenRecorder: bitrate must be a positive integer in kbps.";
    }
    {
      assertion = bitrateMode == "cbr" || builtins.elem quality [ "medium" "high" "very_high" "ultra" ];
      message = "useGpuScreenRecorder: quality must be a supported preset when bitrateMode is not cbr.";
    }
  ];

  programs.gpu-screen-recorder.enable = true;

  systemd.user.services.gpu-screen-recorder = {
    description = "GPU Screen Recorder (Replay Mode)";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p -- ${lib.escapeShellArg outputPath}";
      ExecStart = "${lib.getExe recorder} ${lib.escapeShellArgs recorderArgs}";
      KillSignal = "SIGINT";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  environment.systemPackages = [
    saveReplay

    (pkgs.makeDesktopItem {
      name = "gsr-save-replay";
      desktopName = "GPU Screen Recorder Save Replay";
      exec = "${saveReplay}/bin/gsr-save-replay";
      icon = "media-record";
      terminal = false;
      type = "Application";
      categories = [ "Utility" ];
    })
  ];
}
