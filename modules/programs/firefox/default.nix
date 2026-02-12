{ enableWidevine ? false }:
{ pkgs, lib, username, aarch64-widevine ? null, ... }: {
  programs.firefox = {
    enable = true;
  };

  nixpkgs.overlays = lib.mkIf (enableWidevine && aarch64-widevine != null) [
    aarch64-widevine.overlays.default
  ];

  environment.variables = lib.mkIf enableWidevine {
    MOZ_GMP_PATH = "${pkgs.widevine-cdm-lacros}/gmp-widevinecdm/system-installed";
  };
}