{ config, lib, pkgs, username, shared, modules, ... }: {
  imports = [
    ./desktop.nix
    ./services.nix
    ./programs.nix
    ./systems.nix
    ./hardware-configuration.nix
  ];

  # Host-specific configuration
  networking.hostName = "rflxn-desktop";

  networking.nameservers = [
    "1.0.0.1"
    "1.1.1.1"
    "8.8.4.4"
    "8.8.8.8"
  ];

  time.timeZone = shared.timezone;
  i18n.defaultLocale = shared.locale;

  networking.firewall.enable = false;

  system.copySystemConfiguration = false;
  system.stateVersion = "25.11";
}
