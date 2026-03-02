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

  useDenoisedMic = import ./denoised-mic.nix;
  useLowLatency = import ./low-latency.nix;
}
