{ username, hostNames, ... }: {
  home-manager.users.${username} = {
    services.syncthing = {
      enable = true;

      settings = {
        devices = {
          "rflxn-macbook" = { id = "UUNNXI2-S5LHREV-GVIDWMB-RBZ5PSO-EQ7LRSY-TDQP3BG-EQAK3XK-ZXEFTQF"; };
          "rflxn-desktop" = { id = "VPLZV5I-NZ3TUQB-DXFHFVG-DJV4UM2-ND4PDQV-QSNH2QB-HF2P6WI-KLLL2Q7"; };
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