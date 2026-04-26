{
  appearance = import ./appearance.nix;
  cursors = import ./cursors;
  keybinds = import ./keybind;
  touchpad = import ./touchpad;
  useAgs = import ./ags;
  useDarkMode = import ./dark-mode.nix;
  useHypridle = import ./hypridle;
  useHyprland = import ./use-hyprland.nix;
  useHyprlock = import ./hyprlock;
  useHyprpolkit = import ./hyprpolkit.nix;
  useHyprshell = import ./hyprshell;
  useTrayBridge = import ./tray-bridge.nix;
  wallpaper = import ./wallpaper;
  windowRules = import ./window-rules;
}
