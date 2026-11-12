{
  usePipewire = { }:
    { pkgs, ... }: {
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = pkgs.stdenv.hostPlatform.isx86_64;
        pulse.enable = true;
        jack.enable = true;
      };
    };

  useDenoisedMic = import ./denoised-mic.nix;
  useLowLatency = import ./low-latency.nix;
  useAudioModes = import ./audio-modes.nix;
}
