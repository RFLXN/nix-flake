{ username, ... }: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${username} = {
      home.stateVersion = "25.11";
      programs.home-manager.enable = true;
    };
  };  
}