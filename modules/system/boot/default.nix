{
  grub = {
    theme = import ./grub/theme;
    useGrub = import ./grub;
  };
  useEfiBoot = import ./efi-boot.nix;
  useLanzaboote = import ./lanzaboote.nix;
  usePlymouth = import ./plymouth.nix;
  useSystemdBoot = import ./systemd-boot.nix;
}
