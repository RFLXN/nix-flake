{ username, hostNames, ... }: {
  home-manager.users.${username} = {
    services.syncthing = {
      enable = true;

      settings = {
        devices = {
          "rflxn-server" = { id = "6DG2UBH-GKCIGUC-FKENX32-BGU6MKQ-RRBD62C-UNNQW7E-4IQEY4L-4T6BYQV"; };
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