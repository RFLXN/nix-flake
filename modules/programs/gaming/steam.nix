{ enableGamescope ? false, enableProtontricks ? false }:
{ pkgs-unstable, lib, ... }: {
  programs.steam = {
    enable = true;
    package = pkgs-unstable.steam;
    gamescopeSession.enable = enableGamescope;
    protontricks = lib.mkIf enableProtontricks {
      enable = true;
      package = pkgs-unstable.protontricks;
    };
  };
}
