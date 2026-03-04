{
  mimeTypes ? [
    "application/pdf"
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
