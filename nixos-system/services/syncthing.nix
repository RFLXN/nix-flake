{ username, hostNames, ... }: {
  home-manager.users.${username} = {
    services.syncthing = {
      enable = true;

      settings = {
        devices = {
          "rflxn-macbook" = { id = "UUNNXI2-S5LHREV-GVIDWMB-RBZ5PSO-EQ7LRSY-TDQP3BG-EQAK3XK-ZXEFTQF"; };
          "rflxn-wsl" = { id = "T63MDRX-YBT3ALB-T7DOJ7L-LJY5N6X-WYQ4TM6-CMKIQDX-2RILOWO-OTHB5QT"; };
        };

        folders = {
          "development" = {
            id = "development";
            path = "~/development";
            devices = [ "rflxn-macbook" "rflxn-wsl" ];
          };

          "data" = {
            id = "data";
            path = "~/data";
            devices = [ "rflxn-macbook" "rflxn-wsl" ];
          };
        };
      };
    };
  };
}