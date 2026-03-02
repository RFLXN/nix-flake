{
  appearance = import ./appearance.nix;
  cursors = import ./cursors;
  keybinds = import ./keybind;
  touchpad = import ./touchpad;
  useAgs = import ./ags;
  useDarkMode = import ./dark-mode.nix;
  useDunst = import ./dunst.nix;
  useHyprbars = import ./hyprbars.nix;
  useHypridle = import ./hypridle;
  useHyprland = import ./use-hyprland.nix;
  useHyprlock = import ./hyprlock;
  useHyprpolkit = import ./hyprpolkit.nix;
  useHyprshell = import ./hyprshell;
  useRofi = import ./rofi.nix;
  useTrayBridge = import ./tray-bridge.nix;
  useWaybar = import ./waybar.nix;
  wallpaper = import ./wallpaper;
  windowRules = import ./window-rules;
}
