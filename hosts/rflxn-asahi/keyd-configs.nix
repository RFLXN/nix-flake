{
  default = {
    ids = [ "*" ];
    settings = {
      main = {
        # Swap cmd (meta) to ctrl
        leftmeta = "leftcontrol";
        rightmeta = "f18";

        # Swap option (alt) to alt (keep as is, but for clarity)
        leftalt = "leftalt";
        rightalt = "rightalt";

        # Swap ctrl to meta
        leftcontrol = "leftmeta";
        rightcontrol = "rightmeta";

        # Enable fn layer
        fn = "layer(fn)";
      };

      # Mac-style ctrl + arrow = home/end (ctrl is physical cmd after swap)
      control = {
        left = "home";
        right = "end";
        backspace = "delete";
      };

      # Enable fn key combinations for special functions
      fn = {
        f1 = "brightnessdown";
        f2 = "brightnessup";
        f3 = "f3";  # Mission Control (handle by desktop)
        f4 = "f4";  # Launchpad (handle by desktop)
        f5 = "micmute";
        f6 = "sleep";
        f7 = "previoussong";
        f8 = "playpause";
        f9 = "nextsong";
        f10 = "mute";
        f11 = "volumedown";
        f12 = "volumeup";
        "3" = "print";
      };
    };
  };
}
