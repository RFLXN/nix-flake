{ enableWidevine ? false }:
# aarch64-widevine is only looked up when enableWidevine is set, so hosts that
# leave it off do not have to pass the input.
{ pkgs, lib, aarch64-widevine, ... }: {
  programs.firefox = {
    enable = true;
  };

  nixpkgs.overlays = lib.mkIf enableWidevine [
    aarch64-widevine.overlays.default
  ];

  environment.variables = lib.mkIf enableWidevine {
    MOZ_GMP_PATH = "${pkgs.widevine-cdm-lacros}/gmp-widevinecdm/system-installed";
  };
}
