{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Terminals
    kitty

    # Editors, IDEs
    vscode
    jetbrains.webstorm
    jetbrains.pycharm
    jetbrains.idea
    jetbrains.gateway

    # Utilities
    stats
    aldente
    alt-tab-macos
  ];
}