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

          # D-Bus and systemd activation (for example "show in folder" from a
          # browser) start Dolphin by absolute store path, which would bypass
          # the wrapper. Point those unit files at the wrapped binary.
          for unit in \
            share/dbus-1/services/org.kde.dolphin.FileManager1.service \
            share/systemd/user/plasma-dolphin.service
          do
            if [ -e "$out/$unit" ]; then
              target="$(readlink -f "$out/$unit")"
              rm "$out/$unit"
              substitute "$target" "$out/$unit" \
                --replace-fail ${lib.escapeShellArg "${kde.dolphin}/bin/dolphin"} "$out/bin/dolphin"
            fi
          done
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
