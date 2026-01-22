{ username, hostNames, ... }: {
  home-manager.users.${username} = {
    services.syncthing = {
      enable = true;

      settings = {
        devices = {
          "rflxn-macbook" = { id = "UUNNXI2-S5LHREV-GVIDWMB-RBZ5PSO-EQ7LRSY-TDQP3BG-EQAK3XK-ZXEFTQF"; };
          "rflxn-server" = { id = "6DG2UBH-GKCIGUC-FKENX32-BGU6MKQ-RRBD62C-UNNQW7E-4IQEY4L-4T6BYQV"; };
        };

        folders = {
          "development" = {
            id = "development";
            path = "~/development";
            devices = [ "rflxn-macbook" "rflxn-server" ];
          };
        };
      };
    };
  };
}