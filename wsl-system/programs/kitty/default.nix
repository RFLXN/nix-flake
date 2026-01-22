{ username, ... }: {
  home-manager.users.${username}.home.file = {
    ".config/kitty/kitty.conf".source = ./kitty.conf;
  };
}