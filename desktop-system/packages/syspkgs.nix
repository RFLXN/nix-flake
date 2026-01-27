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
    
    os-prober
    ntfs3g
  ] ++ (with pkgs-unstable; [
    protonplus
  ]);
}