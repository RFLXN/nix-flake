{ pkgs, ... }: {
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            # Remap Right Alt to F18 (unused function key for IME trigger)
            # This consumes the Alt press so it won't trigger menus
            rightalt = "f18";
          };
        };
      };
    };
  };
}
