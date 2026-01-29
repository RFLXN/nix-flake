{ username, hostNames, ... }: {
  home-manager.users.${username} = {
    services.syncthing = {
      enable = true;

      settings = {
        devices = {
          "rflxn-server" = { id = "IFPCOTB-SSBDOLC-EWEAKI3-QWPXICY-JYLR4XU-PGYKYCH-T6NMQOR-KTWDWAK"; };
        };

        folders = {
          "development" = {
            id = "development";
            path = "~/development";
            devices = [ "rflxn-server" ];
          };
          "data" = {
            id = "data";
            path = "/mnt/shared/Data";
            devices = [ "rflxn-server" ];
          };
        };
      };
    };
  };
}