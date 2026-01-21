{ username, hostNames, ... }: {
  home-manager.users.${username} = {
    services.syncthing = {
      enable = true;

      settings = {
        devices = {};

        folders = {
          "development" = {
            id = "development";
            path = "~/development";
            devices = [];
          };
        };
      };
    };
  };
}