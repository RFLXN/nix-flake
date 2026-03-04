{  }:
{ username, ... }:
let
  inherit (import ./utils.nix) mkMimeDefaults;
  kittyMimeTypes = [
    "application/x-sh"
    "application/x-shellscript"
    "text/x-shellscript"
  ];
in {
  home-manager.users.${username} = {
    xdg.desktopEntries.kitty-shellscript = {
      name = "Kitty (Shell Script)";
      exec = "kitty sh %f";
      type = "Application";
      terminal = false;
      noDisplay = true;
      mimeType = kittyMimeTypes;
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = mkMimeDefaults "kitty-shellscript.desktop" kittyMimeTypes;
      associations.added = mkMimeDefaults "kitty-shellscript.desktop" kittyMimeTypes;
    };
  };
}
