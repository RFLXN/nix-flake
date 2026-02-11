{ }:
{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.wl-clipboard
    pkgs.wayland-utils
  ];
}
