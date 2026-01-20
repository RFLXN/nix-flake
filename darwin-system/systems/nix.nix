{ username, ... }: {
  system.stateVersion = 6;
  system.primaryUser = username;

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];

    gc = {
      automatic = true;
      interval = [
        {
          Hour = 0;
          Minute = 5;
          Weekday = 2;
        }
      ];
    };

    optimise = {
      automatic = true;
      interval = [
        {
          Hour = 0;
          Minute = 5;
          Weekday = 2;
        }
      ];
    };
  };
}