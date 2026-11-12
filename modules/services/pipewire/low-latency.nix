{
  quantum ? 64,
  defaultRate ? 48000,
  allowedRates ? [
    44100
    48000
    88200
    96000
    176400
    192000
    352800
    384000
    705600
    768000
  ],
  resampleQuality ? 10,
}:
{ lib, ... }:
let
  # PipeWire scales quantum values with the graph rate, so this fraction keeps
  # the same duration at every sample rate.
  quantumFraction = "${toString quantum}/${toString defaultRate}";
in
{
  assertions = [
    {
      assertion = lib.isInt quantum && quantum > 0;
      message = "pipewire.useLowLatency: quantum must be a positive integer.";
    }
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
      assertion = lib.isInt resampleQuality && resampleQuality >= 0 && resampleQuality <= 14;
      message = "pipewire.useLowLatency: resampleQuality must be an integer from 0 to 14.";
    }
  ];

  services.pipewire.extraConfig = {
    # The graph quantum is otherwise the smallest latency any client asks for,
    # and a recorder or player asking for a large buffer keeps it large.
    # Pinning min = default = max makes every client run at the low quantum.
    pipewire."92-low-latency"."context.properties" = {
      "default.clock.rate" = defaultRate;
      "default.clock.allowed-rates" = allowedRates;
      "default.clock.quantum" = quantum;
      "default.clock.min-quantum" = quantum;
      "default.clock.max-quantum" = quantum;
    };

    # PulseAudio clients (most games, through Wine/Proton or SDL) are clamped to
    # 256 frames by default; let them request buffers down to the quantum.
    pipewire-pulse."92-low-latency" = {
      "pulse.properties" = {
        "pulse.min.req" = quantumFraction;
        "pulse.min.frag" = quantumFraction;
        "pulse.min.quantum" = quantumFraction;
      };
      "stream.properties"."resample.quality" = resampleQuality;
    };

    client."92-low-latency"."stream.properties"."resample.quality" = resampleQuality;
  };

  # Streams whose rate differs from the graph rate are resampled; raise the
  # quality on the device side as well.
  services.pipewire.wireplumber.extraConfig."92-resample-quality"."monitor.alsa.rules" = [
    {
      matches = [
        { "node.name" = "~alsa_output.*"; }
        { "node.name" = "~alsa_input.*"; }
      ];
      actions.update-props."resample.quality" = resampleQuality;
    }
  ];
}
