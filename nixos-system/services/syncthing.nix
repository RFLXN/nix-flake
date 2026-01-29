{ username, hostNames, ... }: {
  services.syncthing = {
    enable = true;

    configDir = "/persist/syncthing/config";
    databaseDir = "/persist/syncthing/db";
    user = username;

    settings = {
      devices = {
        "rflxn-macbook" = { id = "UUNNXI2-S5LHREV-GVIDWMB-RBZ5PSO-EQ7LRSY-TDQP3BG-EQAK3XK-ZXEFTQF"; };
        "rflxn-desktop" = { id = "63DJZE5-GC3RSIV-UANZZEE-O4JL4EV-4CDOGPD-HCSDGHP-ZX4XFRI-ZA47DAM"; };
      };
      
      folders = {
        "development" = {
          id = "development";
          path = "/home/${username}/development";
          devices = [ "rflxn-macbook" "rflxn-desktop" ];
        };

        "data" = {
          id = "data";
          path = "/home/${username}/data";
          devices = [ "rflxn-desktop" ];
        };
      };
    };
  };
}