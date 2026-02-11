# Args -> NixOS Module
{
  canTouchEfiVariables ? false,
  consoleMode ? null,
  configurationLimit ? null,
}:

{ lib, ... }: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = canTouchEfiVariables;
  boot.loader.systemd-boot.consoleMode = lib.mkIf (consoleMode != null) consoleMode;
  boot.loader.systemd-boot.configurationLimit = lib.mkIf (configurationLimit != null) configurationLimit;
}
