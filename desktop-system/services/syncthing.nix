{ username, hostNames, ... }: {
  home-manager.users.${username} = {
    services.syncthing = {
      enable = true;

      settings = {
        devices = {
        };

        folders = {
        };
      };
    };
  };
}