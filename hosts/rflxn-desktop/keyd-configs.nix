{
  default = {
    ids = [ "*" ];
    settings = {
      main = {
        # Remap Right Alt to F18 (unused function key for IME trigger)
        # This consumes the Alt press so it won't trigger menus
        rightalt = "f18";

        # Explicit passthrough for shift keys to prevent remapping issues
        leftshift = "leftshift";
        rightshift = "rightshift";
      };
    };
  };
}
