{
  mimeTypes ? [
    "application/json"
    "application/ld+json"
    "application/toml"
    "application/xml"
    "application/x-yaml"
    "text/css"
    "text/html"
    "text/javascript"
    "text/markdown"
    "text/plain"
    "text/x-c"
    "text/x-c++hdr"
    "text/x-c++src"
    "text/x-chdr"
    "text/x-csrc"
    "text/x-go"
    "text/x-ini"
    "text/x-java"
    "text/x-python"
    "text/x-rust"
    "text/x-typescript"
    "text/x-yaml"
    "text/xml"
  ]
}:
{ username, ... }:
let
  inherit (import ./utils.nix) mkMimeDefaults;
in {
  home-manager.users.${username}.xdg.mimeApps = {
    enable = true;
    defaultApplications = mkMimeDefaults "code.desktop" mimeTypes;
    associations.added = mkMimeDefaults "code.desktop" mimeTypes;
  };
}
