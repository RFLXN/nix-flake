{
  color ? "dark",
  kvantumTranslucentWindows ? true,
  kvantumBlurring ? true,
  kvantumPopupBlurring ? true,
  kvantumReduceWindowOpacity ? 12,
}:
{ lib, pkgs, username, ... }:
let
  kvantumThemes = {
    light = "Matcha-sea";
    dark = "Matcha-sea-dark";
  };
  colorSchemeFiles = {
    light = "MatchaSea.colors";
    dark = "MatchaSeaDark.colors";
  };
  kvantumTheme = kvantumThemes.${color};
  colorSchemeFile = colorSchemeFiles.${color};

  translucentValue = if kvantumTranslucentWindows then "true" else "false";
  blurringValue = if kvantumBlurring then "true" else "false";
  popupBlurringValue = if kvantumPopupBlurring then "true" else "false";

  matchaKde = pkgs.stdenvNoCC.mkDerivation {
    pname = "matcha-kde";
    version = "0-unstable-2020-08-14";

    src = pkgs.fetchFromGitHub {
      owner = "vinceliuice";
      repo = "Matcha-kde";
      rev = "a3b247bcd6a4892d6b56716ecd495bb6c542fd4f";
      hash = "sha256-f4dlZWjo76U0u0nEbdDnFzlprTi1HgVeoo8Mxi9VsCA=";
    };

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p \
        "$out/share/Kvantum" \
        "$out/share/aurorae/themes" \
        "$out/share/color-schemes" \
        "$out/share/plasma/desktoptheme" \
        "$out/share/plasma/look-and-feel" \
        "$out/share/sddm/themes" \
        "$out/share/wallpapers/Matcha"

      cp -R Kvantum/* "$out/share/Kvantum/"
      cp -R aurorae/* "$out/share/aurorae/themes/"
      cp -R color-schemes/*.colors "$out/share/color-schemes/"
      cp -R plasma/desktoptheme/* "$out/share/plasma/desktoptheme/"
      cp -R plasma/look-and-feel/* "$out/share/plasma/look-and-feel/"
      cp -R sddm/Matcha "$out/share/sddm/themes/"
      cp -R wallpaper/*.jpg "$out/share/wallpapers/Matcha/"

      find "$out/share/Kvantum" -type f -name '*.kvconfig' | while read -r cfg; do
        sed -i -E \
          -e "s/^translucent_windows=.*/translucent_windows=${translucentValue}/" \
          -e "s/^blurring=.*/blurring=${blurringValue}/" \
          -e "s/^popup_blurring=.*/popup_blurring=${popupBlurringValue}/" \
          -e "s/^reduce_window_opacity=.*/reduce_window_opacity=${toString kvantumReduceWindowOpacity}/" \
          "$cfg"
      done

      runHook postInstall
    '';

    meta = with lib; {
      description = "Matcha theme for KDE Plasma and Kvantum";
      homepage = "https://github.com/vinceliuice/Matcha-kde";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
    };
  };
in
{
  assertions = [
    {
      assertion = builtins.hasAttr color kvantumThemes;
      message = "qt.theme.useMatcha: color must be one of \"light\" or \"dark\".";
    }
    {
      assertion = kvantumReduceWindowOpacity >= 0 && kvantumReduceWindowOpacity <= 100;
      message = "qt.theme.useMatcha: kvantumReduceWindowOpacity must be between 0 and 100.";
    }
  ];

  environment.systemPackages = with pkgs; [
    libsForQt5.qt5ct
    qt6Packages.qt6ct
    libsForQt5.qtstyleplugin-kvantum
    qt6Packages.qtstyleplugin-kvantum
    matchaKde
  ];

  home-manager.users.${username} = {
    qt = {
      enable = true;
      platformTheme.name = "qtct";

      qt5ctSettings = {
        Appearance = {
          style = "kvantum";
          color_scheme_path = "${matchaKde}/share/color-schemes/${colorSchemeFile}";
        };
      };

      qt6ctSettings = {
        Appearance = {
          style = "kvantum";
          color_scheme_path = "${matchaKde}/share/color-schemes/${colorSchemeFile}";
        };
      };
    };

    home.file = {
      ".config/Kvantum/kvantum.kvconfig".text = ''
        [General]
        theme=${kvantumTheme}
      '';

      ".config/Kvantum/${kvantumTheme}" = {
        source = "${matchaKde}/share/Kvantum/${kvantumTheme}";
        recursive = true;
      };
    };
  };
}
