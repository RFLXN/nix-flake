{ username, hostNames, ... }: {
  home-manager.users.${username} = {
    services.syncthing = {
      enable = true;

      settings = {
        devices = {
          "rflxn-server" = { id = "6DG2UBH-GKCIGUC-FKENX32-BGU6MKQ-RRBD62C-UNNQW7E-4IQEY4L-4T6BYQV"; };
          "rflxn-wsl" = { id = "T63MDRX-YBT3ALB-T7DOJ7L-LJY5N6X-WYQ4TM6-CMKIQDX-2RILOWO-OTHB5QT"; };
        };

        folders = {
          "development" = {
            id = "development";
            path = "~/development";
            devices = [ "rflxn-server" "rflxn-wsl" ];
          };
          "data" = {
            id = "data";
            path = "~/data";
            devices = [ "rflxn-server" "rflxn-wsl" ];
          };
        };
      };
    };
  };
}