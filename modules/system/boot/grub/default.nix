# Args -> NixOS Module
{
  timeout ? null,
  configurationLimit ? 10,
  defaultEntry ? 0,
  gfxmodeEfi ? "auto",
  gfxpayloadEfi ? "keep",
  timeoutStyle ? "menu",
  useOSProber ? false,
}:

{ lib, ... }: {
  boot.loader.timeout = lib.mkIf (timeout != null) timeout;

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    default = defaultEntry;
    inherit configurationLimit gfxmodeEfi gfxpayloadEfi timeoutStyle useOSProber;
  };
}
