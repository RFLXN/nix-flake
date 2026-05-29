{ withSilentKdeDeps ? false }:
{ pkgs, lib, ... }:
let
  kde = pkgs.kdePackages;

  dolphinPackage =
    if withSilentKdeDeps then
      pkgs.symlinkJoin {
        name = "dolphin-with-silent-kde-deps";
        paths = [ kde.dolphin ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram "$out/bin/dolphin" \
            --prefix PATH : ${lib.makeBinPath [
              kde.kservice
              kde.kde-cli-tools
            ]} \
            --prefix XDG_DATA_DIRS : ${lib.makeSearchPath "share" [
              kde.kservice
              kde.kde-cli-tools
              kde.kio-extras
            ]} \
            --run '${lib.getExe' kde.kservice "kbuildsycoca6"} >/dev/null 2>&1 || true'
        '';
      }
    else
      kde.dolphin;
in {
  # Outside Plasma, Dolphin/KService needs both xdg.mimeApps defaults
  # (desktop.defaultApps.*) and a valid XDG applications menu
  # (for example, hyprland.useXdgMenu) to resolve "Open With" handlers.
  environment.systemPackages = [ dolphinPackage ];
}
