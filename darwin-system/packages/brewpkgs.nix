{ username, ... }: {
  environment.variables = {
    HOMEBREW_NO_ANALYTICS = "1";
  };

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    
    user = username;
  };

  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";

    user = username;

    masApps = {

    };

    brews = [

    ];

    casks = [
      "keka"
      "kekaexternalhelper"

      "font-fira-code"

      # etc.
      "microsoft-edge"
      "spotify"
      "discord"
      "iina"
      "karabiner-elements"
    ];
  };
}
