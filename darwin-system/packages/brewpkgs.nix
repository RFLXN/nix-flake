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
      "kitty"

      "stats"
      "aldente"
      "alt-tab"
      "karabiner-elements"
      "keka"
      "kekaexternalhelper"

      "font-fira-code"

      # editor/ide
      "webstorm"
      "pycharm"
      "intellij-idea"
      "jetbrains-gateway"
      "visual-studio-code"

      # etc.
      "microsoft-edge"
      "spotify"
      "discord"
      "iina"
    ];
  };
}
