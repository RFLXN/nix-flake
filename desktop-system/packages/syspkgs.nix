{ pkgs, pkgs-unstable, ... }: {
  environment.systemPackages = with pkgs; [
    # editor, ide
    vscode

    # terminal
    kitty

    # etc.
    spotify
    discord

    # gaming
    lact
    lutris
    protonup-qt
    gamescope
    wine
    r2modman

    # system
    os-prober
    ntfs3g
    kdePackages.sddm-kcm  # SDDM configuration module for KDE System Settings
    wayland-utils
    wl-clipboard
  ] ++ (with pkgs-unstable; [
    protonplus
    ayugram-desktop
  ]);
}