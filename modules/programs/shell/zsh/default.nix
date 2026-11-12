{ }:
{ pkgs, lib, username, ... }: {
  users.users.${username}.shell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    # oh-my-zsh runs compinit and Powerlevel10k sets the prompt from the user's
    # zshrc, so skip the system-wide copies of both.
    enableGlobalCompInit = false;
    promptInit = "";
  };

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
      source ${./p10k.zsh}
    '';
  };
}
