let
  keybinds = import ./keybind;
in
{
  appearance = import ./appearance.nix;
  cursors = import ./cursors;
  keybind = keybinds;
  keybinds = keybinds;
  touchpad = import ./touchpad;
  useAgs = import ./ags;
  useDarkMode = import ./dark-mode.nix;
  useHypridle = import ./hypridle;
  useHyprland = import ./use-hyprland.nix;
  useHyprlock = import ./hyprlock;
  useHyprpolkit = import ./hyprpolkit.nix;
  useHyprshell = import ./hyprshell;
  useTrayBridge = import ./tray-bridge.nix;
  useXdgMenu = import ./xdg-menu.nix;
  useXdgUserDirs = import ./xdg-user-dirs.nix;
  wallpaper = import ./wallpaper;
  windowRules = import ./window-rules;
}
