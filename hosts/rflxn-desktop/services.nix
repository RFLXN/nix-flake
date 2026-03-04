{ modules, pkgs, shared, username, ... }: {
  imports = with modules.services; [
    (pipewire.useDenoisedMic {})
    (pipewire.useLowLatency {})
    (pipewire.usePipewire {})
    (useDocker { isBtrfs = true; isRootless = true; })
    (useFlatpak {})
    (useGpuScreenRecorder { window = "DP-3"; })
    (useHomeManager { backupCommand = "${pkgs.trash-cli}/bin/trash"; })
    (useKeyd { settings = import ./keyd-configs.nix; })
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
