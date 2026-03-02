{
  boot = import ./boot;
  nix = import ./nix;
  useCjkFonts = import ./fonts;
  useFcitx5 = import ./ime;
  useImpermanence = import ./impermanence;
  useMe = import ./me;
  useNetworkManager = import ./network-manager;
  useZram = import ./zram;
}
