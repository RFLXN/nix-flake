{ username, pkgs, lib, ... }: {
  home-manager.users.${username}.programs.zsh = {
    initContent = lib.mkOrder 1000 ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      ${builtins.readFile ./p10k.zsh}
    '';
  };
}