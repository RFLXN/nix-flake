{ username, hostNames, ... }: {
  home-manager.users.${username} = {
    services.syncthing = {
      enable = true;

      settings = {
        devices = {
          "rflxn-server" = { id = "J2RQDV7-7RSZ3HX-YQJLCRM-7UUPUH4-MYKG4KN-VZYGJKZ-MX5HGX6-7QN3BQR"; };
        };

        folders = {
          "development" = {
            id = "development";
            path = "~/development";
            devices = [ "rflxn-server" ];
          };
        };
      };
    };
  };
}