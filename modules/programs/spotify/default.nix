{
  withAlsaExclusive ? { },
}:
{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  isAarch64Linux = pkgs.stdenv.hostPlatform.isAarch64 && pkgs.stdenv.hostPlatform.isLinux;
  enableAlsaExclusive = withAlsaExclusive.enable or false;
  pipewireTarget = withAlsaExclusive.pipewire-target or "";
  exclusiveProfile = withAlsaExclusive.profile or null;
  exclusiveRate = withAlsaExclusive.rate or 44100;
  suspendExisting = withAlsaExclusive.suspend-existing or false;
  parkingTarget = withAlsaExclusive.parking-target or "spotify-exclusive-park";

  spotifyAlsa = pkgs.writeShellApplication {
    name = "spotify-alsa";
    text = ''
      session_args=(
        --target ${lib.escapeShellArg pipewireTarget}
        --parking-target ${lib.escapeShellArg parkingTarget}
        --rate ${toString exclusiveRate}
        --spotify ${lib.getExe pkgs.spotify}
        --pactl ${lib.getExe' pkgs.pulseaudio "pactl"}
        --pw-dump ${lib.getExe' pkgs.pipewire "pw-dump"}
        --pw-link ${lib.getExe' pkgs.pipewire "pw-link"}
        --pgrep ${lib.getExe' pkgs.procps "pgrep"}
      )
      ${lib.optionalString (exclusiveProfile != null) ''
        session_args+=(--profile ${lib.escapeShellArg exclusiveProfile})
      ''}
      ${lib.optionalString suspendExisting ''
        session_args+=(--suspend-existing)
      ''}
      exec ${lib.getExe pkgs.python3} ${./exclusive-session.py} "''${session_args[@]}" -- "$@"
    '';
  };

  spotifyAlsaDesktop = pkgs.makeDesktopItem {
    name = "spotify-alsa";
    desktopName = "Spotify: Alsa Exclusive";
    genericName = "Music Player";
    exec = "${spotifyAlsa}/bin/spotify-alsa %U";
    icon = "spotify-client";
    startupWMClass = "spotify";
    terminal = false;
    type = "Application";
    categories = [
      "Audio"
      "Music"
      "Player"
      "AudioVideo"
    ];
  };
in
lib.mkMerge [
  {
    environment.systemPackages =
      if isAarch64Linux then
        [
          pkgs.spotify-qt
          pkgs.librespot
        ]
      else
        [ pkgs.spotify ];

    home-manager.users.${username} = {
      home.activation.configureSpotifyQt = lib.mkIf isAarch64Linux (
        config.home-manager.users.${username}.lib.dag.entryAfter [ "writeBoundary" ] ''
          CONFIG_FILE="/home/${username}/.config/kraxarn/spotify-qt.json"
          if [ -f "$CONFIG_FILE" ]; then
            ${pkgs.jq}/bin/jq '.Spotify.path = "${pkgs.librespot}/bin/librespot" | .Spotify.start_client = true' "$CONFIG_FILE" > "$CONFIG_FILE.tmp"
            mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
          fi
        ''
      );
    };
  }

  (lib.mkIf enableAlsaExclusive {
    assertions = [
      {
        assertion = !isAarch64Linux;
        message = "useSpotify.withAlsaExclusive is only supported by the official Spotify Linux client.";
      }
      {
        assertion = config.services.pipewire.enable && config.services.pipewire.pulse.enable;
        message = "useSpotify.withAlsaExclusive requires PipeWire with PulseAudio compatibility enabled.";
      }
      {
        assertion =
          lib.isString pipewireTarget && builtins.match "^[A-Za-z0-9._:@/+-]+$" pipewireTarget != null;
        message = "useSpotify.withAlsaExclusive.pipewire-target must be a non-empty PipeWire sink node name without whitespace.";
      }
      {
        assertion = exclusiveProfile == null || (lib.isString exclusiveProfile && exclusiveProfile != "");
        message = "useSpotify.withAlsaExclusive.profile must be null or a non-empty profile name.";
      }
      {
        assertion = lib.isInt exclusiveRate && exclusiveRate > 0;
        message = "useSpotify.withAlsaExclusive.rate must be a positive sample rate.";
      }
      {
        assertion = lib.isBool suspendExisting;
        message = "useSpotify.withAlsaExclusive.suspend-existing must be a boolean.";
      }
      {
        assertion =
          !suspendExisting
          || (
            lib.isString parkingTarget
            && builtins.match "^[A-Za-z0-9._:@/+-]+$" parkingTarget != null
            && parkingTarget != pipewireTarget
          );
        message = "useSpotify.withAlsaExclusive.parking-target must be a non-empty sink node name distinct from pipewire-target.";
      }
    ];

    services.pipewire.extraConfig.pipewire = lib.mkIf suspendExisting {
      "95-spotify-exclusive-park" = {
        "context.objects" = [
          {
            factory = "adapter";
            args = {
              "factory.name" = "support.null-audio-sink";
              "node.name" = parkingTarget;
              "node.description" = "Spotify Exclusive Parking";
              "media.class" = "Audio/Sink";
              "audio.position" = [
                "FL"
                "FR"
              ];
              "node.virtual" = true;
              "priority.driver" = 1;
              "priority.session" = 1;
              "object.linger" = true;
            };
          }
        ];
      };
    };

    environment.systemPackages = [
      spotifyAlsa
      spotifyAlsaDesktop
    ];
  })
]
