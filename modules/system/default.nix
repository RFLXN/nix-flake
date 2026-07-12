{
  boot = import ./boot;
  nix = import ./nix;
  useCjkFonts = import ./fonts;
  useFcitx5 = import ./ime;
  useFirewall = import ./firewall;
  useImpermanence = import ./impermanence;
  useMe = import ./me;
  useNetworkManager = import ./network-manager;
  useZram = import ./zram;
}
