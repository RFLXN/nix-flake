{ pkgs, ... }: {
  "context.modules" = [
    {
      name = "libpipewire-module-filter-chain";
      args = {
        "node.description" = "Noise Canceling Source";
        "media.name" = "Noise Canceling Source";
        "filter.graph" = {
          nodes = [
            {
              type = "ladspa";
              name = "rnnoise";
              plugin = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
              label = "noise_suppressor_stereo";
              control = {
                "VAD Threshold (%)" = 50.0;
              };
            }
          ];
        };
        "audio.position" = [ "FL" "FR" ];
        "capture.props" = {
          "node.name" = "capture.rnnoise_source";
          "node.passive" = true;
          "audio.rate" = 48000;
        };
        "playback.props" = {
          "node.name" = "rnnoise_source";
          "media.class" = "Audio/Source";
          "audio.rate" = 48000;
        };
      };
    }
  ];
}