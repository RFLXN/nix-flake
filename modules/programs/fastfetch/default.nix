{ beforeModules ? [], afterModules ? [] }:
{ pkgs, username, ... }:
let
  config = {
    logo.source = "NixOS";
    modules = beforeModules ++ [
      "break"
      "separator"

      "break"

      "os"
      "kernel"
      "bootmgr"

      "break"

      "cpu"
      "gpu"
      "board"
      "memory"
      "disk"

      "break"

      "de"
      "lm"
      "wm"

      "break"

      "colors"
    ] ++ afterModules;
  };
in {
  environment.systemPackages = [ pkgs.fastfetch ];

  home-manager.users.${username}.home.file = {
    ".config/fastfetch/config.jsonc".text = builtins.toJSON config;
  };
}
