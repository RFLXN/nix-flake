{ enableGamescope ? false, enableProtontricks ? false }:
{ pkgs, lib, ... }:
{
  programs.gamescope = {
    enable = enableGamescope;
    package = pkgs.gamescope;
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
    extraPackages = lib.optionals enableGamescope [ pkgs.gamescope ];
    package = pkgs.steam.override {
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
      package = pkgs.protontricks;
    };
  };
}
