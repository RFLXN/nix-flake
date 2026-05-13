{
  listenPort ? 10514,
  incomingInterface ? null,
  outgoingInterface ? incomingInterface,
  clientCidr ? null,
  portRange ? "1024:65535",
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
  incomingMatch = lib.optionalString (incomingInterface != null) "-i ${incomingInterface}";
  outgoingMatch = lib.optionalString (outgoingInterface != null) "-o ${outgoingInterface}";
  clientMatch = lib.optionalString (clientCidr != null) "-s ${clientCidr}";

  preroutingRules = lib.concatMapStringsSep "\n" (range: ''
    iptables -w -t nat -A XIVMITM_PRE ${incomingMatch} ${clientMatch} -d ${range} -p tcp --dport ${portRange} -j DNAT --to-destination 127.0.0.1:${toString listenPort}
  '') ranges;

  postroutingRules = lib.concatMapStringsSep "\n" (range: ''
    iptables -w -t nat -A XIVMITM_POST ${outgoingMatch} ${clientMatch} -d ${range} -j MASQUERADE
  '') ranges;
in
{
  assertions = [
    {
      assertion = ranges != [];
      message = "xivmitm gateway redirect needs at least one FFXIV server range.";
    }
    {
      assertion = listenPort > 0 && listenPort < 65536;
      message = "xivmitm gateway listenPort must be a valid TCP port.";
    }
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = lib.mkDefault 1;
    "net.ipv4.conf.all.route_localnet" = 1;
    "net.ipv4.conf.default.route_localnet" = 1;
  } // lib.optionalAttrs (incomingInterface != null) {
    "net.ipv4.conf.${incomingInterface}.route_localnet" = 1;
  };

  environment.systemPackages = [ pkgs.iptables ];

  systemd.services.ffxiv-xivmitm-gateway = {
    description = "Redirect routed FFXIV traffic to XivMitmLatencyMitigator";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    path = [ pkgs.iptables ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      iptables -w -t nat -N XIVMITM_PRE 2>/dev/null || true
      iptables -w -t nat -N XIVMITM_POST 2>/dev/null || true
      iptables -w -t nat -F XIVMITM_PRE
      iptables -w -t nat -F XIVMITM_POST

      while iptables -w -t nat -D PREROUTING -p tcp -j XIVMITM_PRE 2>/dev/null; do :; done
      while iptables -w -t nat -D POSTROUTING -j XIVMITM_POST 2>/dev/null; do :; done
      iptables -w -t nat -I PREROUTING 1 -p tcp -j XIVMITM_PRE
      iptables -w -t nat -I POSTROUTING 1 -j XIVMITM_POST

      ${preroutingRules}
      ${postroutingRules}
    '';

    preStop = ''
      while iptables -w -t nat -D PREROUTING -p tcp -j XIVMITM_PRE 2>/dev/null; do :; done
      while iptables -w -t nat -D POSTROUTING -j XIVMITM_POST 2>/dev/null; do :; done
      iptables -w -t nat -F XIVMITM_PRE 2>/dev/null || true
      iptables -w -t nat -F XIVMITM_POST 2>/dev/null || true
      iptables -w -t nat -X XIVMITM_PRE 2>/dev/null || true
      iptables -w -t nat -X XIVMITM_POST 2>/dev/null || true
    '';
  };
}
