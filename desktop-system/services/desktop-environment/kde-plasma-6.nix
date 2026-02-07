{ pkgs, username, ... }: {
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    kate
    konsole
    okular
  ];

  home-manager.users.${username} = {
    programs.plasma = {
      enable = true;
      overrideConfig = true;
    };
  };

  imports = [
    ./plasma-6/shortcuts.nix
    ./plasma-6/visual.nix
    ./plasma-6/mice.nix
  ];
}