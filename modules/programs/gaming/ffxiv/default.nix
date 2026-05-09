{
  enableFileSecret ? false,
  enableDotNetIPv6 ? true,
}:
{ pkgs, lib, xivlauncher-rb, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  xivlauncher = xivlauncher-rb.packages.${system}.xivlauncher-rb;
  envVars =
    lib.optionals enableFileSecret [ "XL_SECRET_PROVIDER=file" ]
    ++ lib.optionals (!enableDotNetIPv6) [ "DOTNET_SYSTEM_NET_DISABLEIPV6=1" ];
  envPrefix = lib.concatStringsSep " " envVars;
  xivlauncherPackage =
    if envVars != [] then
      pkgs.symlinkJoin {
        name = "${xivlauncher.name}-desktop-env";
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
              sed -i 's|^Exec=|Exec=env ${envPrefix} |' "$desktopFile"
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
