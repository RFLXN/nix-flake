{
  useDefaults = import ./defaults.nix;
  useAudioModeToggle = import ./audio-mode-toggle.nix;
  useDankLinuxLauncher = import ./dank-linux-launcher.nix;
  useKitty = import ./kitty.nix;
  useGsrSaveReplay = import ./gsr-save-replay.nix;
  useScreenOff = import ./screen-off.nix;
  useHyprshot = import ./hyprshot.nix;
  useMediaFunctions = import ./media-functions.nix;
  useToggleMonitorSetup = import ./toggle-monitor-setup.nix;
}
