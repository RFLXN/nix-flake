{
  useSystemdBoot = import ./systemd-boot;
  nix = import ./nix;
  useNetworkManager = import ./network-manager;
  useZram = import ./zram;
  useImpermanence = import ./impermanence;
  useMe = import ./me;
  useFcitx5 = import ./ime;
  useCjkFonts = import ./fonts;
}
