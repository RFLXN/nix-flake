{ pkgs, username, ... }: {
  imports = [
    ./p10k.nix
  ];

  environment.variables = {
    EDITOR = "nano";
  };

  environment.shells = with pkgs; [
    bash
    zsh
  ];

  users.users.${username}.shell = pkgs.zsh;

  programs.zsh = {
    enable = true;
  };

  home-manager.users.${username}.programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {

    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };
  };
}