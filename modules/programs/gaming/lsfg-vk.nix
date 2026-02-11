{ }:
{ pkgs-unstable, ... }: {
  environment.systemPackages = [
    pkgs-unstable.lsfg-vk
    pkgs-unstable.lsfg-vk-ui
  ];
}
