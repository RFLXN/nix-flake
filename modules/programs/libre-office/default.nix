{ }:
{ pkgs, ... }:
let
  libreofficeDefaultTheme = pkgs.symlinkJoin {
    name = "libreoffice-qt-fresh-default-theme";
    paths = [ pkgs.libreoffice-qt-fresh ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      # Force LO to use Qt6 backend while bypassing global qtct/kvantum overrides.
      wrapProgram $out/bin/libreoffice \
        --set SAL_USE_VCLPLUGIN qt6 \
        --set QT_QPA_PLATFORMTHEME qt6ct \
        --unset QT_STYLE_OVERRIDE
    '';
  };
in
{
  environment.systemPackages = [ libreofficeDefaultTheme ];
}
