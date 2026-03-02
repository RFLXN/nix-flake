{
  useEfiBoot = import ./efi-boot.nix;
  useLanzaboote = import ./lanzaboote.nix;
  usePlymouth = import ./plymouth.nix;
  useSystemdBoot = import ./systemd-boot.nix;
}
