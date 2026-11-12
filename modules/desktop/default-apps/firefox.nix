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
  inherit (import ./utils.nix) mkMimeDefaults mkMimeApps;
in {
  home-manager.users.${username}.xdg.mimeApps = mkMimeApps (mkMimeDefaults "firefox.desktop" mimeTypes);
}
