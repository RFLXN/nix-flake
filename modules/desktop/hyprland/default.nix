{
  useHyprland = import ./use-hyprland.nix;
  keybinds = import ./keybind;
  appearance = import ./appearance.nix;
  useDunst = import ./dunst.nix;
  useRofi = import ./rofi.nix;
  useDarkMode = import ./dark-mode.nix;
  useHyprshell = import ./hyprshell;
  useHyprpolkit = import ./hyprpolkit.nix;
  useHyprpaper = import ./hyprpaper;
  useWaybar = import ./waybar.nix;
  cursors = import ./cursors;
  useAgs = import ./ags;
  useTrayBridge = import ./tray-bridge.nix;
  windowRules = import ./window-rules;
  useHyprbars = import ./hyprbars.nix;
}
