{ pkgs, ... }: {
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # C/C++ standard libraries
      stdenv.cc.cc.lib

      # Compression libraries
      zlib
      zstd
      bzip2
      xz

      # Cryptography and security
      openssl

      # Networking
      curl

      # System libraries
      glib
      glibc

      # Graphics and rendering
      libGL
      libGLU
      mesa
      vulkan-loader

      # X11 libraries
      xorg.libX11
      xorg.libXcursor
      xorg.libXi
      xorg.libXrandr
      xorg.libXext
      xorg.libXfixes
      xorg.libXrender
      xorg.libxcb
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXinerama
      xorg.libXScrnSaver

      # Wayland
      libxkbcommon
      wayland

      # Audio
      alsa-lib
      pulseaudio
      libsndfile

      # Fonts and text rendering
      freetype
      fontconfig
      cairo
      pango
      harfbuzz

      # Image libraries
      libpng
      libjpeg
      libtiff
      libwebp

      # GTK/Qt dependencies
      gtk3
      gdk-pixbuf
      atk
      at-spi2-atk
      dbus

      # Qt5 libraries
      qt5.qtbase
      qt5.qtdeclarative
      qt5.qtwayland

      # Qt6 libraries (in case the app uses Qt6)
      qt6.qtbase
      qt6.qtdeclarative
      qt6.qtwayland

      # Other common libraries
      expat
      libffi
      libuuid
      ncurses
      readline
      sqlite
      libxml2
      libusb1

      # Development tools libraries
      elfutils
      libcap
      libseccomp
    ];
  };
}