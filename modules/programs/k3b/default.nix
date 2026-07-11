{ }:
{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.kdePackages.k3b ];
}
