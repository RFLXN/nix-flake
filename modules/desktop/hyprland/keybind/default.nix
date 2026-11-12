{
  useDefaults = import ./defaults.nix;
  useDankLinuxLauncher = import ./dank-linux-launcher.nix;
  useKitty = import ./kitty.nix;
  useGsrSaveReplay = import ./gsr-save-replay.nix;
  useScreenOff = import ./screen-off.nix;
  useHyprshot = import ./hyprshot.nix;
  useMediaFunctions = import ./media-functions.nix;
  useToggleMonitorSetup = import ./toggle-monitor-setup.nix;
}
