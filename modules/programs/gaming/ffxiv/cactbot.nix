{ }:
{ pkgs, lib, ... }:
let
  mkCactbotWebapp =
    {
      name,
      desktopName,
      class,
      url,
      allowAudioAutoplay ? false,
    }:
    let
      chromiumArgs =
        [
          "--class=${class}"
        ]
        ++ lib.optionals allowAudioAutoplay [
          "--autoplay-policy=no-user-gesture-required"
        ]
        ++ [
          "--app=${url}"
        ];

      script = pkgs.writeShellScriptBin name ''
        profile_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/cactbot/${name}"
        mkdir -p "$profile_dir"

        exec ${pkgs.chromium}/bin/chromium \
          --user-data-dir="$profile_dir" \
          ${lib.escapeShellArgs chromiumArgs}
      '';

      desktop = pkgs.makeDesktopItem {
        inherit name desktopName;
        exec = "${script}/bin/${name}";
        icon = "chromium";
        terminal = false;
        type = "Application";
        categories = [
          "Game"
          "Utility"
        ];
        startupWMClass = class;
      };
    in
    pkgs.symlinkJoin {
      inherit name;
      paths = [
        script
        desktop
      ];
    };

  cactbotRaidboss = mkCactbotWebapp {
    name = "cactbot-raidboss";
    desktopName = "Cactbot - Raidboss";
    class = "cactbot-raidboss-overlay";
    url = "http://proxy.iinact.com/overlay/cactbot/ui/raidboss/raidboss.html?OVERLAY_WS=ws://127.0.0.1:10501/ws";
    allowAudioAutoplay = true;
  };

  cactbotConfiguration = mkCactbotWebapp {
    name = "cactbot-configuration";
    desktopName = "Cactbot - Configuration";
    class = "cactbot-configuration-overlay";
    url = "http://proxy.iinact.com/overlay/cactbot/ui/config/config.html?OVERLAY_WS=ws://127.0.0.1:10501/ws";
  };
in
{
  environment.systemPackages = [
    cactbotRaidboss
    cactbotConfiguration
  ];
}
