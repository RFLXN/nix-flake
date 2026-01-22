{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    jetbrains.gateway
  ];
}