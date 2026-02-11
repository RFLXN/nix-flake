{
  usePipewire = { }:
    { ... }: {
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };
    };

  useLowLatency = import ./low-latency.nix;
  useDenoisedMic = import ./denoised-mic.nix;
}
