{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # editor, ide
    vscode

    # terminal
    kitty

    fira-code

    os-prober
  ];
}