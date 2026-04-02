{
  mimeTypes ? [
    "application/pdf"
    "application/xhtml+xml"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
  ]
}:
{ username, ... }:
let
  inherit (import ./utils.nix) mkMimeDefaults;
in {
  home-manager.users.${username}.xdg.mimeApps = {
    enable = true;
    defaultApplications = mkMimeDefaults "firefox.desktop" mimeTypes;
    associations.added = mkMimeDefaults "firefox.desktop" mimeTypes;
  };
}
