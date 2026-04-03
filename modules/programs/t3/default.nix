{ }:
{ pkgs, t3code, ... }: {
  nixpkgs.overlays = [ t3code.overlays.default ];

  environment.systemPackages = [ pkgs.t3code ];
}
