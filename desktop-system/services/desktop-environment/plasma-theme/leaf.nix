{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "leaf-kde";
  version = "unstable-2024-12-28";

  src = fetchFromGitHub {
    owner = "qewer33";
    repo = "leaf-kde";
    rev = "main";
    sha256 = "sha256-5KY9JmIfwqWd/i2EW4su4v/f7PO/dFyu097Pxn6liWA=";  # You'll need to update this after first build
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share

    # Install look-and-feel (global themes)
    if [ -d "look-and-feel" ]; then
      mkdir -p $out/share/plasma/look-and-feel
      cp -r look-and-feel/* $out/share/plasma/look-and-feel/
    fi

    # Install desktop theme
    if [ -d "desktoptheme/Leaf" ]; then
      mkdir -p $out/share/plasma/desktoptheme
      cp -r desktoptheme/Leaf $out/share/plasma/desktoptheme/
    fi

    # Install color schemes
    if [ -d "color-schemes" ]; then
      mkdir -p $out/share/color-schemes
      cp -r color-schemes/* $out/share/color-schemes/
    fi

    # Install Aurorae themes
    if [ -d "aurorae" ]; then
      mkdir -p $out/share/aurorae/themes
      cp -r aurorae/* $out/share/aurorae/themes/
    fi

    # Install wallpapers
    if [ -d "wallpapers" ]; then
      mkdir -p $out/share/wallpapers
      cp -r wallpapers/* $out/share/wallpapers/
    fi

    runHook postInstall
  '';

  meta = with lib; {
    description = "Leaf theme for KDE Plasma";
    homepage = "https://github.com/qewer33/leaf-kde";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
