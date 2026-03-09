{ }:
{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.kdePackages.kdenlive ];
}
