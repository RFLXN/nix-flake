{
  enableFileSecret ? false,
}:
{ pkgs, xivlauncher-rb, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  xivlauncher = xivlauncher-rb.packages.${system}.xivlauncher-rb;
  xivlauncherPackage =
    if enableFileSecret then
      pkgs.symlinkJoin {
        name = "${xivlauncher.name}-file-secret";
        paths = [ xivlauncher ];
        postBuild = ''
          shopt -s nullglob
          desktopFiles=("$out"/share/applications/*.desktop)

          if [ "''${#desktopFiles[@]}" -eq 0 ]; then
            echo "xivlauncher-rb package did not expose a desktop file" >&2
            exit 1
          fi

          patched=0
          for desktopFile in "''${desktopFiles[@]}"; do
            if grep -q '^Exec=' "$desktopFile"; then
              sed -i 's|^Exec=|Exec=env XL_SECRET_PROVIDER=file |' "$desktopFile"
              patched=1
            fi
          done

          if [ "$patched" -eq 0 ]; then
            echo "xivlauncher-rb desktop file did not contain an Exec line" >&2
            exit 1
          fi
        '';
      }
    else
      xivlauncher;
in
{
  environment.systemPackages = [ xivlauncherPackage ];
}
