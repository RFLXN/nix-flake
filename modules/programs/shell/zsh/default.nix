{ }:
{ pkgs, lib, username, ... }: {
  environment.shells = [ pkgs.zsh ];

  users.users.${username}.shell = pkgs.zsh;

  programs.zsh.enable = true;

  home-manager.users.${username}.programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };

    initContent = lib.mkOrder 1000 ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      ${builtins.readFile ./p10k.zsh}
    '';
  };
}
