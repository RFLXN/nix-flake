{ hostNames, ... }: {
  networking.hostName = hostNames.home-server;

  # Enable firewall but allow all traffic (needed for iptables to load)
  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [ { from = 1; to = 65535; } ];
    allowedUDPPortRanges = [ { from = 1; to = 65535; } ];
    trustedInterfaces = [ "docker0" ];
  };

  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];

  # Enable IP forwarding for Docker
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # Networking: systemd-networkd for wired DHCP
  networking.useDHCP = false;
  systemd.network = {
    enable = true;
    networks."10-lan" = {
      matchConfig.Type = "ether";
      networkConfig.DHCP = "yes";
    };
  };
}