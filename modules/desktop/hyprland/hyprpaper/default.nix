{ wallpaper ? null, monitors ? [], wallpapers ? [] }:
{ username, pkgs, lib, ... }:
let
  usePerMonitor = wallpapers != [];
  resolvedMonitors = if monitors == [] then [ "" ] else monitors;

  legacyWallpapers =
    if usePerMonitor then
      map (w: "${w.monitor},${w.path}") wallpapers
    else if wallpaper != null then
      map (m: "${m},${wallpaper}") resolvedMonitors
    else
      [];

  legacyPreload =
    if usePerMonitor then map (w: w.path) wallpapers
    else if wallpaper != null then [ wallpaper ]
    else [];

  newWallpapers =
    if usePerMonitor then
      map (w:
        let
          base = {
            monitor = w.monitor or "";
            path = w.path;
          };
        in base // (builtins.removeAttrs w [ "monitor" "path" ])
      ) wallpapers
    else if wallpaper != null then
      map (m: { monitor = m; path = wallpaper; }) resolvedMonitors
    else
      [];

  useNewFormat = lib.versionAtLeast (pkgs.hyprpaper.version or "0") "0.8.0";
  resolvedWallpapers = if useNewFormat then newWallpapers else legacyWallpapers;
in {
  assertions = [
    {
      assertion = resolvedWallpapers != [];
      message = "useHyprpaper requires wallpaper (and optional monitors) or a wallpapers list.";
    }
  ];

  home-manager.users.${username}.services.hyprpaper = {
    enable = true;
    settings =
      if useNewFormat then
        { wallpaper = newWallpapers; }
      else
        {
          preload = legacyPreload;
          wallpaper = legacyWallpapers;
        };
  };
}
