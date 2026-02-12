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

        # Note: Fn key is handled by Asahi kernel, not keyd
      };

      # Mac-style ctrl + arrow = home/end (ctrl is physical cmd after swap)
      control = {
        left = "home";
        right = "end";
        backspace = "delete";
      };
    };
  };
}
