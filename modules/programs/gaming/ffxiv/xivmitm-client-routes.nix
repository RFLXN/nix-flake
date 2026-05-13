{
  gateway,
  interface,
  ranges ? [
    "119.252.36.0/24"
    "119.252.37.0/24"
    "153.254.80.0/24"
    "204.2.29.0/24"
    "80.239.145.0/24"
  ],
}:
{ lib, pkgs, ... }:
let
  routeUp = lib.concatMapStringsSep "\n" (range: ''
    ip route replace ${range} via ${gateway} dev ${interface}
  '') ranges;

  routeDown = lib.concatMapStringsSep "\n" (range: ''
    ip route del ${range} via ${gateway} dev ${interface} 2>/dev/null || true
  '') ranges;
in
{
  assertions = [
    {
      assertion = ranges != [];
      message = "xivmitm client routes need at least one FFXIV server range.";
    }
  ];

  systemd.services.ffxiv-xivmitm-client-routes = {
    description = "Route FFXIV traffic through the XivMitmLatencyMitigator gateway";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    path = [ pkgs.iproute2 ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = routeUp;
    preStop = routeDown;
  };
}
