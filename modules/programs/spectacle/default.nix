{ }:
{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.kdePackages.spectacle ];
}
