{
  lockScreenPasswordField = {
    width = 420;
    height = 56;
    radius = 28;
    backgroundColor = "#181818";
    backgroundOpacity = 0.85;
    borderColor = "#5e5e5e";
    focusBorderColor = "#f4f4f4";
    showLockIcon = false;
  };

  settings = {
    configVersion = 16;

    currentThemeCategory = "registry";
    registryThemeVariants.deepmono.dark = {
      flavor = "mono";
      accent = "fog";
    };
    cornerRadius = 18;
    fontFamily = "Pretendard";
    fontWeight = 300;
    fontScale = 1.5;
    textRenderQuality = 4;
    animationSpeed = 2;
    springBounce = 0;

    clockFormat = "12h";
    showSeconds = true;
    clockDateFormat = "yyyy-MM-dd";
    lockDateFormat = "yyyy-MM-dd";
    weatherEnabled = false;

    lockAtStartup = true;
    loginctlLockIntegration = true;
    lockScreenShowSystemIcons = false;
    lockScreenShowProfileImage = false;
    lockScreenShowMediaPlayer = false;
    lockScreenNotificationMode = 2;
    lockScreenWallpaperPath = "/home/rflxn/Pictures/main-wallpaper.jpg";
    lockScreenFontFamily = "Pretendard Light";

    dankLauncherV2Size = "large";
    dankLauncherV2ShowSourceBadges = false;
    dankLauncherV2ShowFooter = false;

    barConfigs = [
      {
        id = "default";
        name = "Main Bar";
        enabled = true;
        position = 0;
        screenPreferences = [ "eDP-1" ];
        showOnLastDisplay = true;
        leftWidgets = [
          "launcherButton"
          {
            id = "focusedWindow";
            enabled = true;
            focusedWindowSize = 0;
            focusedWindowShowIcon = true;
            focusedWindowCompactMode = true;
          }
        ];
        centerWidgets = [
          {
            id = "workspaceSwitcher";
            enabled = true;
          }
          {
            id = "clock";
            enabled = true;
            clockCompactMode = false;
            clockDateOrder = "dateFirst";
          }
        ];
        rightWidgets = [
          {
            id = "notificationButton";
            enabled = true;
          }
          "systemTray"
          "controlCenterButton"
        ];
        spacing = 0;
        transparency = 1;
        widgetTransparency = 1;
        bottomGap = 0;
        innerPadding = 12;
        widgetPadding = 8;
        barInsetPadding = 16;
        barLengthPadding = 0;
        popupGapsAuto = true;
        popupGapsManual = 50;
        iconScale = 1;
        noBackground = false;
        maximizeWidgetIcons = false;
        maximizeWidgetText = false;
        removeWidgetPadding = false;
        squareCorners = false;
        borderEnabled = false;
        widgetOutlineEnabled = false;
        widgetOutlineColor = "primary";
        widgetOutlineThickness = 10;
        shadowIntensity = 0;
        attachToScreenEdge = true;
        gothCornersEnabled = true;
        gothCornerRadiusOverride = true;
        gothCornerRadiusValue = 23;
      }
    ];
  };

  theme = builtins.fromJSON (builtins.readFile ./dank-linux-theme.json);
}
