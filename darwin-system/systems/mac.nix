{ ... }: {
  system.defaults = {
    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;

    CustomUserPreferences = {
      "com.apple.screencapture" = {
        disable-shadow = true;
      };

      "com.apple.menuextra.clock" = {
        DateFormat = "d MMM EEE a h:mm:ss";
        IsAnalog = false;
      };

      "com.apple.HIToolbox" = {
        AppleFnUsageType = 0;
      };
    };

    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleInterfaceStyleSwitchesAutomatically = false;
      AppleMeasurementUnits = "Centimeters";
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      AppleTemperatureUnit = "Celsius";
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticInlinePredictionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSDocumentSaveNewDocumentsToCloud = false;
      "com.apple.keyboard.fnState" = true;
    };

    loginwindow = {
      DisableConsoleAccess = false;
      GuestEnabled = false;
      PowerOffDisabledWhileLoggedIn = false;
      RestartDisabled = false;
      RestartDisabledWhileLoggedIn = false;
      ShutDownDisabled = false;
      ShutDownDisabledWhileLoggedIn = false;
      SleepDisabled = false;
    };

    dock = {
      autohide = false;
      largesize = 16;
      launchanim = true;
      magnification = true;
      mineffect = "genie";
      orientation = "bottom";
      persistent-apps = [
        { app = "/System/Applications/Apps.app"; }
        { app = "/Applications/Microsoft Edge.app"; }
        { app = "/System/Applications/Phone.app"; }
        { app = "/System/Applications/Messages.app"; }
        { app = "/Applications/Discord.app"; }
        { app = "/Applications/Spotify.app"; }
        { app = "/Applications/kitty.app"; }
        { app = "/Applications/Visual Studio Code.app"; }
        { app = "/System/Applications/App Store.app"; }
      ];
    };
  };
}