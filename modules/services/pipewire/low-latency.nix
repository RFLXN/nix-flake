{
  defaultRate ? 48000,
  allowedRates ? [
    44100
    48000
    88200
    96000
    176400
    192000
  ],
  defaultQuantum ? 256,
  minQuantum ? 64,
  maxQuantum ? 2048,
}:
{ lib, ... }:
{
  assertions = [
    {
      assertion = lib.isInt defaultRate && defaultRate > 0;
      message = "pipewire.useLowLatency: defaultRate must be a positive integer.";
    }
    {
      assertion = allowedRates != [ ] && lib.all (rate: lib.isInt rate && rate > 0) allowedRates;
      message = "pipewire.useLowLatency: allowedRates must be a non-empty list of positive integers.";
    }
    {
      assertion = builtins.elem defaultRate allowedRates;
      message = "pipewire.useLowLatency: allowedRates must include defaultRate.";
    }
    {
      assertion =
        lib.isInt minQuantum
        && lib.isInt defaultQuantum
        && lib.isInt maxQuantum
        && minQuantum > 0
        && minQuantum <= defaultQuantum
        && defaultQuantum <= maxQuantum;
      message = "pipewire.useLowLatency: quantum values must be positive integers satisfying minQuantum <= defaultQuantum <= maxQuantum.";
    }
  ];

  services.pipewire.extraConfig.pipewire."92-low-latency" = {
    "context.properties" = {
      "default.clock.rate" = defaultRate;
      "default.clock.allowed-rates" = allowedRates;
      "default.clock.quantum" = defaultQuantum;
      "default.clock.min-quantum" = minQuantum;
      "default.clock.max-quantum" = maxQuantum;
    };
  };
}
