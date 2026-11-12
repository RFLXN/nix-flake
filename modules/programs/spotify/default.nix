{ }:
{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  isAarch64Linux = pkgs.stdenv.hostPlatform.isAarch64 && pkgs.stdenv.hostPlatform.isLinux;
in
{
  # The official client has no aarch64-linux build; use spotify-qt with
  # librespot there.
  environment.systemPackages =
    if isAarch64Linux then
      [
        pkgs.spotify-qt
        pkgs.librespot
      ]
    else
      [ pkgs.spotify ];

  home-manager.users.${username} = {
    home.activation.configureSpotifyQt = lib.mkIf isAarch64Linux (
      config.home-manager.users.${username}.lib.dag.entryAfter [ "writeBoundary" ] ''
        CONFIG_FILE="$HOME/.config/kraxarn/spotify-qt.json"
        if [ -f "$CONFIG_FILE" ]; then
          # A broken config file must not abort the whole activation.
          if ${pkgs.jq}/bin/jq '.Spotify.path = "${pkgs.librespot}/bin/librespot" | .Spotify.start_client = true' "$CONFIG_FILE" > "$CONFIG_FILE.tmp"; then
            mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
          else
            rm -f "$CONFIG_FILE.tmp"
            echo "spotify-qt.json could not be updated; leaving it untouched" >&2
          fi
        fi
      ''
    );
  };
}
