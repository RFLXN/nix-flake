{
  useEfiBoot = import ./efi-boot.nix;
  useSystemdBoot = import ./systemd-boot.nix;
  useLanzaboote = import ./lanzaboote.nix;
  usePlymouth = import ./plymouth.nix;
}
