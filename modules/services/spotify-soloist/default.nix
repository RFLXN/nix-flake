# Spotify Soloist: headless Spotify Connect receiver.
#
# Runs as a systemd user service so it plays through the user's PipeWire
# session. The upstream `services.soloist` NixOS module is not used because it
# requires system-wide PipeWire, which these desktop hosts do not run.
#
# The API key comes from the Spotify for Developers dashboard
# (https://developer.spotify.com/dashboard/soloist). Keep it in `keyFile`; the
# file must be readable by `username`. Soloist state lives in
# ~/.local/share/soloist and ~/.cache/soloist, which stay under the persisted
# /home, so no extra impermanence entries are needed.
{
  keyFile,
  deviceName ? null,
  initialVolume ? null,
  pipewireDevice ? null,
  cacheSize ? null,
  websocketAddress ? null,
  verbose ? false,
  extraArgs ? [ ],
}:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  name = if deviceName != null then deviceName else config.networking.hostName;

  args =
    [
      "--device-name"
      name
    ]
    ++ lib.optionals (initialVolume != null) [
      "--initial-volume"
      (toString initialVolume)
    ]
    ++ lib.optionals (pipewireDevice != null) [
      "--pipewire-device"
      pipewireDevice
    ]
    ++ lib.optionals (cacheSize != null) [
      "--cache-size"
      (toString cacheSize)
    ]
    ++ lib.optionals (websocketAddress != null) [
      "--ws"
      websocketAddress
    ]
    ++ lib.optional verbose "--verbose"
    ++ extraArgs;

  soloistService = pkgs.writeShellScript "spotify-soloist" ''
    set -euo pipefail

    key_file=${lib.escapeShellArg keyFile}
    if [[ ! -r "$key_file" ]]; then
      echo "spotify-soloist: API key file $key_file is missing or not readable" >&2
      exit 1
    fi

    api_key="$(${pkgs.coreutils}/bin/tr -d '[:space:]' < "$key_file")"
    if [[ -z "$api_key" ]]; then
      echo "spotify-soloist: API key file $key_file is empty" >&2
      exit 1
    fi

    exec ${lib.getExe pkgs.soloist} --api-key "$api_key" ${lib.escapeShellArgs args}
  '';
in
{
  assertions = [
    {
      assertion = lib.isString keyFile && lib.hasPrefix "/" keyFile;
      message = "useSpotifySoloist: keyFile must be an absolute path string outside the Nix store.";
    }
    {
      assertion = lib.isString name && name != "";
      message = "useSpotifySoloist: deviceName must be a non-empty string.";
    }
    {
      assertion = initialVolume == null || (lib.isInt initialVolume && initialVolume >= 0 && initialVolume <= 100);
      message = "useSpotifySoloist: initialVolume must be null or an integer between 0 and 100.";
    }
    {
      assertion = pipewireDevice == null || (lib.isString pipewireDevice && pipewireDevice != "");
      message = "useSpotifySoloist: pipewireDevice must be null or a non-empty PipeWire node name/ID.";
    }
    {
      assertion = cacheSize == null || (lib.isInt cacheSize && (cacheSize == 0 || cacheSize >= 100));
      message = "useSpotifySoloist: cacheSize must be null, 0 (no limit), or at least 100 (MB).";
    }
    {
      assertion = websocketAddress == null || (lib.isString websocketAddress && builtins.match ".+:[0-9]+" websocketAddress != null);
      message = "useSpotifySoloist: websocketAddress must be null or an ADDR:PORT string.";
    }
    {
      assertion = lib.isBool verbose;
      message = "useSpotifySoloist: verbose must be a boolean.";
    }
    {
      assertion = lib.isList extraArgs && lib.all lib.isString extraArgs;
      message = "useSpotifySoloist: extraArgs must be a list of strings.";
    }
    {
      assertion = config.services.pipewire.enable;
      message = "useSpotifySoloist requires services.pipewire.enable.";
    }
  ];

  # Exposes `soloist ctl ...` for controlling the running instance.
  environment.systemPackages = [ pkgs.soloist ];

  systemd.user.services.spotify-soloist = {
    description = "Spotify Soloist headless Spotify Connect client";
    documentation = [ "https://developer.spotify.com/documentation/soloist" ];
    wantedBy = [ "graphical-session.target" ];
    after = [
      "graphical-session.target"
      "pipewire.service"
      "pipewire-pulse.service"
    ];
    wants = [ "pipewire.service" ];
    partOf = [ "graphical-session.target" ];

    unitConfig = {
      StartLimitIntervalSec = 60;
      StartLimitBurst = 5;
    };

    serviceConfig = {
      Type = "simple";
      ExecStart = "${soloistService}";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
