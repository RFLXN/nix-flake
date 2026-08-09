{ modules, pkgs, shared, username, ... }: {
  imports = with modules.services; [
    (pipewire.useDenoisedMic {})
    (pipewire.useLowLatency {})
    (pipewire.usePipewire {})
    (pipewire.useProfileChanger {
      defaultProfile = "game";
      profiles = [
        {
          name = "game";
          label = "Gaming · 48 kHz / 64";
          description = "E30 is managed by PipeWire at 48 kHz with a 64-frame quantum.";
          icon = "applications-games";
          rate = 48000;
          quantum = 64;
          deviceProfiles = [
            {
              device = "alsa_card.usb-Topping_E30-00";
              profile = "HiFi";
            }
          ];
          startUserServices = [
            "easyeffects.service"
            "gpu-screen-recorder.service"
          ];
        }
        {
          name = "hifi";
          label = "Hi-Fi · PipeWire Exclusive";
          description = "E30 stays on PipeWire at 44.1 kHz for one exclusive, DSP-free playback stream.";
          icon = "audio-card";
          rate = 44100;
          deviceProfiles = [
            {
              device = "alsa_card.usb-Topping_E30-00";
              profile = "HiFi";
            }
          ];
          stopUserServices = [
            "easyeffects.service"
            "gpu-screen-recorder.service"
          ];
        }
      ];
    })
    (useDocker { isBtrfs = true; isRootless = true; })
    (useEasyEffects {})
    (useFlatpak {})
    (useGpuScreenRecorder { window = "DP-3"; })
    (useHomeManager { backupCommand = "${pkgs.trash-cli}/bin/trash"; })
    (useKeyd { settings = import ./keyd-configs.nix; })
    (useRemovableStorageAutoMount {})
    (useRtkit {})
    (useSyncthing {
      serviceLevel = "user";
      devices = { inherit (shared.syncthing-devices) rflxn-server; };
      folders = {
        "development" = {
          id = "development";
          path = "/home/${username}/development";
          devices = [ "rflxn-server" ];
        };
        "data" = {
          id = "data";
          path = "/mnt/shared/Data";
          devices = [ "rflxn-server" ];
        };
      };
    })
    (useTailscale {})
  ];
}
