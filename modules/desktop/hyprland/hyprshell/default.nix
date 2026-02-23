{ modifier ? "alt" }:
{ pkgs, username, ... }@args:
let
  system = pkgs.stdenv.hostPlatform.system;
  hyprshellInput = args.hyprshell or null;
  hyprshellPackage = if hyprshellInput != null then hyprshellInput.packages.${system}.default else pkgs.hyprshell;
in {
  home-manager.users.${username} = {
    wayland.windowManager.hyprland.settings.exec-once = [ "hyprshell run" ];

    services.hyprshell = {
      enable = true;
      package = hyprshellPackage;
      systemd.enable = false;
      style = builtins.readFile ./styles.css;
      settings = {
        version = 3;
        windows = {
          scale = 3.5;
          items_per_row = 10;
          overview = null;
          switch = {
            inherit modifier;
            filter_by = [];
            switch_workspaces = false;
          };
        };
      };
    };
  };
}
