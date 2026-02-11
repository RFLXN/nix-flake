# Args -> NixOS Module
{
  consoleMode ? null,
  configurationLimit ? 15,
}:

{ lib, ... }: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = lib.mkIf (consoleMode != null) consoleMode;
  boot.loader.systemd-boot.configurationLimit = lib.mkIf (configurationLimit != null) configurationLimit;
}
