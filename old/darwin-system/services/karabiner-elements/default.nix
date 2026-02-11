{ username, ... }: {
  home-manager.users.${username} = {
    home.file.".config/karabiner/karabiner.json".source = ./karabiner.json;
  };
}