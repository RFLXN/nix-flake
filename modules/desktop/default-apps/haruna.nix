{  }:
{ username, ... }:
let
  inherit (import ./utils.nix) mkMimeDefaults;
  harunaMimeTypes = [
    "audio/aac"
    "audio/ac3"
    "audio/flac"
    "audio/mp4"
    "audio/mpeg"
    "audio/ogg"
    "audio/vnd.wave"
    "audio/webm"
    "audio/x-matroska"
    "audio/x-mpegurl"
    "video/mp2t"
    "video/mp4"
    "video/mpeg"
    "video/ogg"
    "video/quicktime"
    "video/vnd.avi"
    "video/webm"
    "video/x-matroska"
    "video/x-ms-wmv"
  ];
in {
  home-manager.users.${username}.xdg.mimeApps = {
    enable = true;
    defaultApplications = mkMimeDefaults "org.kde.haruna.desktop" harunaMimeTypes;
    associations.added = mkMimeDefaults "org.kde.haruna.desktop" harunaMimeTypes;
  };
}
