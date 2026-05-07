{  }:
{ pkgs, xivlauncher-rb, ... }: {
  environment.systemPackages = [ xivlauncher-rb.packages.${pkgs.system}.xivlauncher-rb ];
}