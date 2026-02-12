{ }:
{ pkgs, pkgs-unstable, lib, username, config, ... }: {
  environment.systemPackages =
    if pkgs.stdenv.hostPlatform.isAarch64 && pkgs.stdenv.hostPlatform.isLinux
      then [ pkgs-unstable.spotify-qt pkgs-unstable.librespot ]
      else [ pkgs-unstable.spotify ];

  home-manager.users.${username} = {
    home.activation.configureSpotifyQt = lib.mkIf
      (pkgs.stdenv.hostPlatform.isAarch64 && pkgs.stdenv.hostPlatform.isLinux)
      (config.home-manager.users.${username}.lib.dag.entryAfter [ "writeBoundary" ] ''
        CONFIG_FILE="/home/${username}/.config/kraxarn/spotify-qt.json"
        if [ -f "$CONFIG_FILE" ]; then
          ${pkgs.jq}/bin/jq '.Spotify.path = "${pkgs-unstable.librespot}/bin/librespot" | .Spotify.start_client = true' "$CONFIG_FILE" > "$CONFIG_FILE.tmp"
          mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        fi
      '');
  };
}
