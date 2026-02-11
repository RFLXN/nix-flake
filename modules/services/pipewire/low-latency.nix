{ }:
{ ... }: {
  services.pipewire.extraConfig.pipewire."92-low-latency" = {
    "context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.allowed-rates" = [ 48000 ];
      "default.clock.quantum" = 64;
      "default.clock.min-quantum" = 64;
      "default.clock.max-quantum" = 64;
    };
  };
}
