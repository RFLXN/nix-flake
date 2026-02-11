{ username, pkgs, ... }: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    backupCommand = "${pkgs.trash-cli}/bin/trash";

    users.${username} = {
      home.stateVersion = "25.11";
      programs.home-manager.enable = true;
    };
  };  
}