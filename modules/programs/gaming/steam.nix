{ enableGamescope ? false, enableProtontricks ? false }:
{ pkgs, lib, ... }:
{
  programs.gamescope = {
    enable = enableGamescope;
    package = pkgs.gamescope;
    capSysNice = false;
  };

  # ananicy is only here to renice gamescope.
  services.ananicy = lib.mkIf enableGamescope {
    enable = true;
    package = pkgs.ananicy-cpp;
    # ananicy-cpp ships no rules; pointing rulesProvider at it would copy the
    # whole package (binary included) into /etc/ananicy.d. Provide an empty
    # rule set and rely on extraRules.
    rulesProvider = pkgs.runCommand "ananicy-no-default-rules" { } ''
      mkdir -p $out/etc/ananicy.d/00-default
    '';
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
        libxcursor
        libxi
        libxinerama
        libxscrnsaver
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
