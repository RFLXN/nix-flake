{ }:
{ pkgs, t3code, ... }: {
  environment.systemPackages = [ t3code.packages.${pkgs.system}.default ];
}
