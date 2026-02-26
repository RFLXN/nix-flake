{ }:
{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.lsfg-vk
    pkgs.lsfg-vk-ui
  ];
}
