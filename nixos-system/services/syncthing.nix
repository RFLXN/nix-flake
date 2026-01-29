{ username, hostNames, ... }: {
  home-manager.users.${username} = {
    services.syncthing = {
      enable = true;

      settings = {
        devices = {
          "rflxn-macbook" = { id = "UUNNXI2-S5LHREV-GVIDWMB-RBZ5PSO-EQ7LRSY-TDQP3BG-EQAK3XK-ZXEFTQF"; };
          "rflxn-desktop" = { id = "63DJZE5-GC3RSIV-UANZZEE-O4JL4EV-4CDOGPD-HCSDGHP-ZX4XFRI-ZA47DAM"; };
        };

        folders = {
          "development" = {
            id = "development";
            path = "~/development";
            devices = [ "rflxn-macbook" "rflxn-desktop" ];
          };

          "data" = {
            id = "data";
            path = "~/data";
            devices = [ "rflxn-desktop" ];
          };
        };
      };
    };
  };
}