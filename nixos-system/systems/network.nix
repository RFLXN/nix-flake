{ hostNames, ... }: {
  networking.hostName = hostNames.home-server;
  networking.firewall.enable = false;
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