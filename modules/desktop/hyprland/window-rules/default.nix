let
  useFixed = import ./fixed.nix;
  fixedClass = class: { workspace }: useFixed { inherit class workspace; };
in
{
  # Kept as an explicit, currently empty, starting point for shared rules.
  useDefaults = { }:
  { username, ... }: {
    home-manager.users.${username}.wayland.windowManager.hyprland.settings.window_rule = [ ];
  };

  inherit useFixed;
  useFixedDiscord = fixedClass "^(discord)$";
  useFixedMopiMopi = fixedClass "^(chrome-proxy\\.iinact\\.com__overlay_mopimopi_-Default)$";
  useFixedSpotify = fixedClass "^(spotify)$";
  useFixedVesktop = fixedClass "^(vesktop)$";
  useHidden = import ./hidden.nix;
}
