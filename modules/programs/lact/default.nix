{ enableDaemon ? true }:
{ pkgs, lib, ... }: {
  environment.systemPackages = [ pkgs.lact ];

  systemd.services.lact = lib.mkIf enableDaemon {
    description = "AMDGPU Control Daemon";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.lact}/bin/lact daemon";
    };
    enable = true;
  };
}
