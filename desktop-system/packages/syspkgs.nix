{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # editor, ide
    vscode

    # terminal
    kitty
    
    # etc.
    spotify
    discord

    os-prober
  ];
}