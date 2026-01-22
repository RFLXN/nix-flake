{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Terminals
    kitty
  ];
}