{
  hifiQuantum ? 1024,
  hifiMinQuantum ? 256,
  hifiMaxQuantum ? 2048,
  hifiStopUserServices ? [ ],
}:
{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  # Runtime flag; %t is the user's XDG_RUNTIME_DIR, so every login starts in
  # gaming mode.
  hifiFlagName = "audio-mode-hifi";

  audioMode = pkgs.writeShellApplication {
    name = "audio-mode";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.jq
      pkgs.libnotify
      pkgs.pipewire
      pkgs.systemd
    ];
    text = ''
      flag="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/${hifiFlagName}"
      services=(${lib.escapeShellArgs hifiStopUserServices})

      current_mode() {
        if [ -e "$flag" ]; then echo hifi; else echo gaming; fi
      }

      set_clock() {
        pw-metadata -n settings 0 "clock.$1" "$2" >/dev/null
      }

      # The value the PipeWire daemon was configured with.
      configured_clock() {
        pw-dump | jq -r --arg key "default.clock.$1" \
          'first(.[] | select(.type == "PipeWire:Interface:Core") | .info.props[$key]) // empty'
      }

      wait_for_pipewire() {
        for _ in $(seq 1 50); do
          if pw-metadata -n settings 0 >/dev/null 2>&1; then
            return 0
          fi
          sleep 0.2
        done
        echo "audio-mode: PipeWire is not reachable" >&2
        return 1
      }

      notify() {
        notify-send --app-name="Audio Mode" --icon="$1" "$2" "$3" >/dev/null 2>&1 || true
      }

      # Hi-Fi: nothing forces a rate or a small quantum. With the always-on
      # streams stopped, the device goes idle between tracks and PipeWire
      # reopens it at each track's native sample rate.
      apply_hifi_clock() {
        set_clock force-rate 0
        set_clock force-quantum 0
        set_clock max-quantum ${toString hifiMaxQuantum}
        set_clock quantum ${toString hifiQuantum}
        set_clock min-quantum ${toString hifiMinQuantum}
      }

      # Gaming: back to whatever the daemon is configured with.
      apply_gaming_clock() {
        set_clock force-rate 0
        set_clock force-quantum 0
        for key in min-quantum quantum max-quantum; do
          value="$(configured_clock "$key")"
          if [ -n "$value" ]; then
            set_clock "$key" "$value"
          fi
        done
      }

      enter_hifi() {
        wait_for_pipewire
        touch "$flag"
        if [ "''${#services[@]}" -gt 0 ]; then
          systemctl --user stop "''${services[@]}" || true
        fi
        apply_hifi_clock
        notify audio-headphones "Hi-Fi mode" "Native sample rate, relaxed buffering."
      }

      enter_gaming() {
        wait_for_pipewire
        rm -f "$flag"
        apply_gaming_clock
        if [ "''${#services[@]}" -gt 0 ]; then
          systemctl --user start "''${services[@]}" || true
        fi
        notify applications-games "Gaming mode" "Lowest latency."
      }

      status() {
        echo "mode: $(current_mode)"
        pw-metadata -n settings 0 2>/dev/null \
          | sed -n "s/.*key:'clock\.\([a-z-]*\)' value:'\([^']*\)'.*/\1 = \2/p" \
          | grep -E '^(rate|quantum|min-quantum|max-quantum|force-rate|force-quantum) ' || true
      }

      case "''${1:-status}" in
        hifi)
          enter_hifi
          ;;
        gaming)
          enter_gaming
          ;;
        toggle)
          if [ "$(current_mode)" = hifi ]; then enter_gaming; else enter_hifi; fi
          ;;
        reapply)
          # Run when PipeWire (re)starts: its runtime settings are gone, the
          # selected mode is not.
          wait_for_pipewire
          if [ "$(current_mode)" = hifi ]; then
            apply_hifi_clock
          fi
          ;;
        status)
          status
          ;;
        *)
          echo "usage: audio-mode [gaming|hifi|toggle|status]" >&2
          exit 2
          ;;
      esac
    '';
  };

  mkModeEntry =
    {
      mode,
      label,
      icon,
    }:
    pkgs.makeDesktopItem {
      name = "audio-mode-${mode}";
      desktopName = "Audio Mode: ${label}";
      exec = "${audioMode}/bin/audio-mode ${mode}";
      inherit icon;
      terminal = false;
      type = "Application";
      categories = [
        "AudioVideo"
        "Audio"
        "Settings"
      ];
    };

  validServiceName = name: lib.isString name && builtins.match "[A-Za-z0-9:_.@-]+\\.service" name != null;
in
{
  assertions = [
    {
      assertion = config.services.pipewire.enable;
      message = "pipewire.useAudioModes requires services.pipewire.enable.";
    }
    {
      assertion =
        lib.all lib.isInt [ hifiMinQuantum hifiQuantum hifiMaxQuantum ]
        && hifiMinQuantum > 0
        && hifiMinQuantum <= hifiQuantum
        && hifiQuantum <= hifiMaxQuantum;
      message = "pipewire.useAudioModes: quantum values must be positive integers satisfying hifiMinQuantum <= hifiQuantum <= hifiMaxQuantum.";
    }
    {
      assertion = lib.isList hifiStopUserServices && lib.all validServiceName hifiStopUserServices;
      message = "pipewire.useAudioModes: hifiStopUserServices must be a list of systemd user unit names ending in .service.";
    }
  ];

  home-manager.users.${username} = {
    home.packages = [
      audioMode
      (mkModeEntry {
        mode = "gaming";
        label = "Gaming";
        icon = "applications-games";
      })
      (mkModeEntry {
        mode = "hifi";
        label = "Hi-Fi";
        icon = "audio-headphones";
      })
    ];

    # Keep the stopped services from coming back (restart policies, PipeWire
    # restarts) for as long as Hi-Fi mode is selected.
    xdg.configFile = lib.listToAttrs (
      map (service: {
        name = "systemd/user/${service}.d/audio-mode.conf";
        value.text = ''
          [Unit]
          ConditionPathExists=!%t/${hifiFlagName}
        '';
      }) hifiStopUserServices
    );

    systemd.user.services.audio-mode = {
      Unit = {
        Description = "Reapply the selected audio mode";
        After = [
          "pipewire.service"
          "wireplumber.service"
        ];
        PartOf = [ "pipewire.service" ];
      };

      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${audioMode}/bin/audio-mode reapply";
      };

      Install.WantedBy = [ "pipewire.service" ];
    };
  };
}
