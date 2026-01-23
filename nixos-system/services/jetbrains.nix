{ username, pkgs, ... }: {
  home-manager.users.${username}.programs.jetbrains-remote = {
    enable = true;
    ides = with pkgs.jetbrains; [
      webstorm
      idea
    ];
  };
}