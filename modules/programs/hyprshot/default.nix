{  }:
{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.hyprshot
  ];
}
