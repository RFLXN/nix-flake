{
  default = {
    ids = [ "*" ];
    settings = {
      main = {
        # Remap Right Alt to the Korean Hangeul key.
        rightalt = "hangeul";
        rightcontrol = "hanja";

        # Explicit passthrough for shift keys to prevent remapping issues
        leftshift = "leftshift";
        rightshift = "rightshift";
      };
    };
  };
}
