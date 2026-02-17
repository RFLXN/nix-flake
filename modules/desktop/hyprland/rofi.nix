{ }:
{ pkgs, username, ... }: {
  home-manager.users.${username}.programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    terminal = "kitty";
    extraConfig = {
      show-icons = true;
      icon-theme = "Papirus";
      display-drun = "Apps";
      drun-display-format = "{name}";
    };
  };
}
