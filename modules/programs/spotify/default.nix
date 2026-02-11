{ }:
{ pkgs, pkgs-unstable, ... }: {
  environment.systemPackages = [
    (if pkgs.stdenv.hostPlatform.isAarch64 && pkgs.stdenv.hostPlatform.isLinux
      then pkgs-unstable.psst
      else pkgs-unstable.spotify)
  ];
}
