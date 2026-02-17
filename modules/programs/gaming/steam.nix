{ enableGamescope ? false, enableProtontricks ? false }:
{ pkgs, pkgs-unstable, lib, ... }:
{
  programs.gamescope = {
    enable = enableGamescope;
    package = pkgs-unstable.gamescope;
    capSysNice = false;
  };

  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-cpp;
    extraRules = [
      {
        "name" = "gamescope";
        "nice" = -20;
      }
    ];
  };

  programs.steam = {
    enable = true;
    # Steam launch options execute inside Steam's FHS environment.
    # Include gamescope there so `gamescope -- %command%` resolves.
    extraPackages = lib.optionals enableGamescope [ pkgs-unstable.gamescope ];
    package = pkgs-unstable.steam.override {
      extraPkgs = pkgs: with pkgs; [
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        libkrb5
        keyutils
      ];
    };
    protontricks = lib.mkIf enableProtontricks {
      enable = true;
      package = pkgs-unstable.protontricks;
    };
  };
}
