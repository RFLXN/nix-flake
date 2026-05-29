{ }:
{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.pcmanfm-qt ];

  services.gvfs.enable = true;
}
