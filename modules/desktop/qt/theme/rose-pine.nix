{
  variant ? "main",
  accent ? "rose",
  useOverlay ? true,
  kvantumTranslucentWindows ? true,
  kvantumBlurring ? true,
  kvantumPopupBlurring ? true,
  kvantumReduceWindowOpacity ? 12
}:
{ lib, pkgs, username, ... }:
let
  variantPrefixes = {
    main = "rose-pine";
    moon = "rose-pine-moon";
    dawn = "rose-pine-dawn";
  };

  allowedAccents = [ "rose" "pine" "foam" "gold" "iris" "love" ];
  kvantumTheme = "${variantPrefixes.${variant}}-${accent}";
  themeSourcePath =
    if useOverlay
    then "${pkgs.rose-pine-kvantum}/share/Kvantum/${kvantumTheme}"
    else "${pkgs.rose-pine-kvantum}/share/Kvantum/themes/${kvantumTheme}";

  translucentValue = if kvantumTranslucentWindows then "true" else "false";
  blurringValue = if kvantumBlurring then "true" else "false";
  popupBlurringValue = if kvantumPopupBlurring then "true" else "false";
in
{
  assertions = [
    {
      assertion = builtins.hasAttr variant variantPrefixes;
      message = "qt.theme.useRosePine: variant must be one of \"main\", \"moon\", or \"dawn\".";
    }
    {
      assertion = builtins.elem accent allowedAccents;
      message = "qt.theme.useRosePine: accent must be one of \"rose\", \"pine\", \"foam\", \"gold\", \"iris\", or \"love\".";
    }
    {
      assertion = kvantumReduceWindowOpacity >= 0 && kvantumReduceWindowOpacity <= 100;
      message = "qt.theme.useRosePine: kvantumReduceWindowOpacity must be between 0 and 100.";
    }
  ];

  nixpkgs.overlays = lib.mkIf useOverlay [
    (_final: prev: {
      rose-pine-kvantum = prev.stdenvNoCC.mkDerivation {
        pname = "rose-pine-kvantum";
        version = "0-unstable-2025-04-16-overlay";

        src = prev.fetchFromGitHub {
          owner = "rose-pine";
          repo = "kvantum";
          rev = "48edf9e2d772b166ed50af3e182a19196e5d3fe6";
          hash = "sha256-0xSMYYPsW7Rw5O8FL0iAt63Hya8GkI2VuOZf64PewyQ=";
        };

        dontBuild = true;
        installPhase = ''
          runHook preInstall

          mkdir -p "$out/share/Kvantum"
          archives="$(find . -type f -name '*.tar.gz')"
          if [ -z "$archives" ]; then
            echo "rose-pine-kvantum overlay: no theme archives found" >&2
            exit 1
          fi
          for archive in $archives; do
            tar -xf "$archive" -C "$out/share/Kvantum"
          done

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

        meta = with prev.lib; {
          description = "Kvantum-themes based on Rose Pine (overlay)";
          homepage = "https://github.com/rose-pine/kvantum";
          platforms = platforms.linux;
          license = licenses.mit;
        };
      };
    })
  ];

  # Ensure Qt apps launched outside Home Manager shell init still receive
  # the expected platform/style overrides (e.g. from Hyprland or rofi).
  environment.sessionVariables = {
    QT_QPA_PLATFORMTHEME = lib.mkDefault "qt5ct";
    QT_STYLE_OVERRIDE = lib.mkDefault "kvantum";
  };
  environment.systemPackages = with pkgs; [
    libsForQt5.qt5ct
    qt6Packages.qt6ct
    libsForQt5.qtstyleplugin-kvantum
    qt6Packages.qtstyleplugin-kvantum
    rose-pine-kvantum
  ];

  home-manager.users.${username} = {
    qt = {
      enable = true;
      platformTheme.name = "qtct";
      style.name = "kvantum";

      # Keep qtct configs explicit so style applies consistently.
      qt5ctSettings = {
        Appearance = {
          style = "kvantum";
        };
      };

      qt6ctSettings = {
        Appearance = {
          style = "kvantum";
        };
      };
    };

    home.file = {
      ".config/Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=${kvantumTheme}
    '';

      ".config/Kvantum/${kvantumTheme}" = {
        source = themeSourcePath;
        recursive = true;
      };
    };
  };
}
