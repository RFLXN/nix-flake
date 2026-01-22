{ username, ... }: {
  home-manager.users.${username} = { config, ... }: {
    home.file."win-drive/c".source = config.lib.file.mkOutOfStoreSymlink "/mnt/c";
    home.file."win-drive/d".source = config.lib.file.mkOutOfStoreSymlink "/mnt/d";
  };
}