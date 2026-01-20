{ ... }: {
  system.stateVersion = "25.11";

  nix = {
    gc = {
      automatic = true;
      dates = "Wed 05:00";
    };

    optimise = {
      automatic = true;
      dates = [ "Wed 05:00" ];
    };
  };
}