{ pkgs, pkgs-unstable, ... }: {
  environment.systemPackages = with pkgs; [
    # terminal
    kitty

    # gaming
    lact
    wine

    # system
    os-prober
    ntfs3g
    kdePackages.sddm-kcm  # SDDM configuration module for KDE System Settings
    wayland-utils
    wl-clipboard

  ] ++ (with pkgs-unstable; [
    # pkgs from unstable channel

    # editor/ide
    vscode

    # etc
    spotify
    ayugram-desktop
    vesktop

    #gaming
    r2modman
    protonplus
    protonup-qt
    lutris
    gamescope
  ]);
}