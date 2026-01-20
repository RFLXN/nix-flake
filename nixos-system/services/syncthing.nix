{ username, hostNames, ... }: {
  home-manager.users.${username} = {
    services.syncthing = {
      enable = true;

      settings = {
        devices = {};

        foldcers = {
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