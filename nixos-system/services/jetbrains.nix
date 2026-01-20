{ pkgs, ... }: {
  home-manager.users.rflxn.programs.jetbrains-remote = {
    enable = true;
    ides = with pkgs.jetbrains; [
      webstorm
      idea
    ];
  };
}