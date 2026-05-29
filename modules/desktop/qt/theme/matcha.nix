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
  kdeglobalsColorSchemes = {
    light = {
      "ColorEffects:Disabled" = {
        Color = "112,111,110";
        ColorAmount = "0";
        ColorEffect = "0";
        ContrastAmount = "0.65";
        ContrastEffect = "1";
        IntensityAmount = "0.1";
        IntensityEffect = "0";
      };
      "ColorEffects:Inactive" = {
        ChangeSelectionColor = true;
        Color = "112,111,110";
        ColorAmount = "0.025";
        ColorEffect = "2";
        ContrastAmount = "0.1";
        ContrastEffect = "2";
        Enable = true;
        IntensityAmount = "0";
        IntensityEffect = "0";
      };
      "Colors:Button" = {
        BackgroundAlternate = "239,239,239";
        BackgroundNormal = "255,255,255";
        DecorationFocus = "46,179,152";
        DecorationHover = "220,220,220";
        ForegroundActive = "255,128,224";
        ForegroundInactive = "153,153,153";
        ForegroundLink = "66,133,244";
        ForegroundNegative = "191,3,3";
        ForegroundNeutral = "176,128,0";
        ForegroundNormal = "48,61,65";
        ForegroundPositive = "0,110,40";
        ForegroundVisited = "224,64,251";
      };
      "Colors:Complementary" = {
        BackgroundAlternate = "52,62,62";
        BackgroundNormal = "27,34,36";
        DecorationFocus = "46,179,152";
        DecorationHover = "79,83,91";
        ForegroundInactive = "110,125,125";
        ForegroundNormal = "171,185,182";
        ForegroundVisited = "224,64,251";
      };
      "Colors:Selection" = {
        BackgroundAlternate = "54,213,179";
        BackgroundNormal = "46,179,152";
        DecorationFocus = "59,231,194";
        DecorationHover = "56,221,186";
        ForegroundActive = "255,128,224";
        ForegroundInactive = "90,220,207";
        ForegroundLink = "66,133,244";
        ForegroundNegative = "156,14,14";
        ForegroundNeutral = "255,221,0";
        ForegroundNormal = "255,255,255";
        ForegroundPositive = "128,255,128";
        ForegroundVisited = "224,64,251";
      };
      "Colors:Tooltip" = {
        BackgroundAlternate = "54,57,62";
        BackgroundNormal = "27,34,36";
        DecorationFocus = "46,179,152";
        DecorationHover = "46,179,152";
        ForegroundActive = "255,128,224";
        ForegroundInactive = "136,136,136";
        ForegroundLink = "66,133,244";
        ForegroundNegative = "191,3,3";
        ForegroundNeutral = "176,128,0";
        ForegroundNormal = "171,185,182";
        ForegroundPositive = "0,110,40";
        ForegroundVisited = "224,64,251";
      };
      "Colors:View" = {
        BackgroundAlternate = "240,240,240";
        BackgroundNormal = "247,247,247";
        DecorationFocus = "46,179,152";
        DecorationHover = "220,220,220";
        ForegroundActive = "255,128,224";
        ForegroundInactive = "136,136,136";
        ForegroundLink = "66,133,244";
        ForegroundNegative = "191,3,3";
        ForegroundNeutral = "176,128,0";
        ForegroundNormal = "48,61,65";
        ForegroundPositive = "0,110,40";
        ForegroundVisited = "224,64,251";
      };
      "Colors:Window" = {
        BackgroundAlternate = "245,245,245";
        BackgroundNormal = "247,247,247";
        DecorationFocus = "46,179,152";
        DecorationHover = "46,179,152";
        ForegroundActive = "255,128,224";
        ForegroundInactive = "153,153,153";
        ForegroundLink = "66,133,244";
        ForegroundNegative = "191,3,3";
        ForegroundNeutral = "176,128,0";
        ForegroundNormal = "48,61,65";
        ForegroundPositive = "0,110,40";
        ForegroundVisited = "224,64,251";
      };
      General = {
        ColorScheme = "MatchaSea";
        ColorSchemeHash = null;
        Name = "MatchaSea";
        shadeSortColumn = true;
      };
      KDE = {
        LookAndFeelPackage = null;
        contrast = "0";
        widgetStyle = "kvantum";
      };
      WM = {
        activeBackground = "27,34,36";
        activeBlend = "34,43,46";
        activeForeground = "171,185,182";
        inactiveBackground = "34,43,46";
        inactiveBlend = "66,77,77";
        inactiveForeground = "111,119,120";
      };
    };
    dark = {
      "ColorEffects:Disabled" = {
        Color = "56,56,56";
        ColorAmount = "0";
        ColorEffect = "0";
        ContrastAmount = "0.65000000000000002";
        ContrastEffect = "1";
        IntensityAmount = "0.10000000000000001";
        IntensityEffect = "2";
      };
      "ColorEffects:Inactive" = {
        ChangeSelectionColor = true;
        Color = "112,111,110";
        ColorAmount = "0.025000000000000001";
        ColorEffect = "2";
        ContrastAmount = "0.10000000000000001";
        ContrastEffect = "2";
        Enable = false;
        IntensityAmount = "0";
        IntensityEffect = "0";
      };
      "Colors:Button" = {
        BackgroundAlternate = "34,43,46";
        BackgroundNormal = "26,34,36";
        DecorationFocus = "46,179,152";
        DecorationHover = "46,179,152";
        ForegroundActive = "60,232,206";
        ForegroundInactive = "102,106,115";
        ForegroundLink = "41,128,185";
        ForegroundNegative = "218,68,83";
        ForegroundNeutral = "246,116,0";
        ForegroundNormal = "211,218,227";
        ForegroundPositive = "39,174,96";
        ForegroundVisited = "46,179,152";
      };
      "Colors:Selection" = {
        BackgroundAlternate = "29,153,243";
        BackgroundNormal = "46,179,152";
        DecorationFocus = "65,255,214";
        DecorationHover = "65,255,214";
        ForegroundActive = "252,252,252";
        ForegroundInactive = "176,214,214";
        ForegroundLink = "253,188,75";
        ForegroundNegative = "218,68,83";
        ForegroundNeutral = "246,116,0";
        ForegroundNormal = "237,246,255";
        ForegroundPositive = "39,174,96";
        ForegroundVisited = "230,171,230";
      };
      "Colors:Tooltip" = {
        BackgroundAlternate = "27,34,36";
        BackgroundNormal = "53,57,69";
        DecorationFocus = "46,179,152";
        DecorationHover = "46,179,152";
        ForegroundActive = "60,232,206";
        ForegroundInactive = "102,106,115";
        ForegroundLink = "41,128,185";
        ForegroundNegative = "218,68,83";
        ForegroundNeutral = "246,116,0";
        ForegroundNormal = "211,218,227";
        ForegroundPositive = "39,174,96";
        ForegroundVisited = "46,179,152";
      };
      "Colors:View" = {
        BackgroundAlternate = "34,43,46";
        BackgroundNormal = "34,43,46";
        DecorationFocus = "46,179,152";
        DecorationHover = "46,179,152";
        ForegroundActive = "60,232,206";
        ForegroundInactive = "102,106,115";
        ForegroundLink = "41,128,185";
        ForegroundNegative = "218,68,83";
        ForegroundNeutral = "246,116,0";
        ForegroundNormal = "211,218,227";
        ForegroundPositive = "39,174,96";
        ForegroundVisited = "46,179,152";
      };
      "Colors:Window" = {
        BackgroundAlternate = "27,34,36";
        BackgroundNormal = "27,34,36";
        DecorationFocus = "46,179,152";
        DecorationHover = "46,179,152";
        ForegroundActive = "60,232,206";
        ForegroundInactive = "102,106,115";
        ForegroundLink = "41,128,185";
        ForegroundNegative = "218,68,83";
        ForegroundNeutral = "246,116,0";
        ForegroundNormal = "211,218,227";
        ForegroundPositive = "39,174,96";
        ForegroundVisited = "46,179,152";
      };
      General = {
        ColorScheme = "MatchaSeaDark";
        ColorSchemeHash = null;
        Name = "MatchaSeaDark";
        shadeSortColumn = true;
      };
      KDE = {
        LookAndFeelPackage = null;
        contrast = "4";
        widgetStyle = "kvantum";
      };
      WM = {
        activeBackground = "27,34,36";
        activeBlend = "27,34,36";
        activeForeground = "211,218,227";
        inactiveBackground = "20,26,27";
        inactiveBlend = "27,34,36";
        inactiveForeground = "102,106,115";
      };
    };
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

  qtThemePackages = with pkgs; [
    qt6Packages.qt6ct
    qt6Packages.qtstyleplugin-kvantum
    matchaKde
  ];
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

  environment.sessionVariables = {
    QT_QPA_PLATFORMTHEME = lib.mkForce "qt6ct";
    QT_STYLE_OVERRIDE = lib.mkForce "kvantum";
  };

  environment.systemPackages = qtThemePackages;

  home-manager.users.${username} = {
    home = {
      packages = qtThemePackages;
      sessionVariables = {
        QT_QPA_PLATFORMTHEME = lib.mkForce "qt6ct";
        QT_STYLE_OVERRIDE = lib.mkForce "kvantum";
      };
    };

    systemd.user.sessionVariables = {
      QT_QPA_PLATFORMTHEME = lib.mkForce "qt6ct";
      QT_STYLE_OVERRIDE = lib.mkForce "kvantum";
    };

    qt = {
      enable = true;

      qt6ctSettings = {
        Appearance = {
          style = "kvantum";
          color_scheme_path = "${matchaKde}/share/color-schemes/${colorSchemeFile}";
        };
      };

      kde.settings.kdeglobals = kdeglobalsColorSchemes.${color};
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
