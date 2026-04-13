{ }:
{ pkgs, quickshell, ... }: {
  environment.systemPackages = [
    quickshell.packages.${pkgs.system}.default
  ];
}
