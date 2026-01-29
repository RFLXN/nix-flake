{ pkgs, pkgs-unstable, ... }: {
  environment.systemPackages = with pkgs; [
    # terminal
    kitty

    # desktop environment
    kdePackages.kolourpaint
    kdePackages.kcalc
    kdePackages.sddm-kcm  # SDDM configuration module for KDE System Settings
    wayland-utils
    wl-clipboard
    hardinfo2
    # gaming
    lact
    wineWowPackages.waylandFull

    # system
    os-prober
    ntfs3g
    dmidecode
    lm_sensors
    
  ] ++ (with pkgs-unstable; [
    # pkgs from unstable channel

    # editor/ide
    vscode

    # etc
    spotify
    ayugram-desktop
    
    (discord.override {
      # withOpenASAR = true; # can do this here too
      withVencord = true;
    })

    #gaming
    r2modman
    protonplus
    protonup-qt
    lutris
    gamescope
  ]);
}