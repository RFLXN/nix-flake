{ pkgs, ... }: {
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    extraConfig.pipewire."92-low-latency" = import ./pipewire/92-low-latency.nix;
    extraConfig.pipewire."99-input-denoising" = import ./pipewire/99-input-denoising.nix { inherit pkgs; };
  };
}