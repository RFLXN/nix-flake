{ hostNames, ... }: {
  networking.hostName = hostNames.wsl;
  networking.firewall.enable = false;
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];
}