{
  settings = {
    configVersion = 16;

    currentThemeCategory = "registry";
    registryThemeVariants.deepmono.dark = {
      flavor = "mono";
      accent = "fog";
    };
    cornerRadius = 4;
    fontFamily = "Pretendard";
    fontWeight = 300;
    fontScale = 1.5;
    textRenderQuality = 4;
    animationSpeed = 2;
    springBounce = 0;

    lockAtStartup = true;
    loginctlLockIntegration = true;

    barConfigs = [
      {
        id = "default";
        name = "Main Bar";
        enabled = true;
        position = 0;
        screenPreferences = [
          {
            name = "DP-3";
            model = "TFG27F20P";
          }
        ];
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
        spacing = 32;
        transparency = 1;
        widgetTransparency = 1;
        bottomGap = 0;
        innerPadding = 12;
        widgetPadding = 7;
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
      {
        id = "bar1788104656727";
        name = "Bar 2";
        enabled = true;
        position = 0;
        screenPreferences = [
          {
            name = "HDMI-A-1";
            model = "VG275";
          }
        ];
        showOnLastDisplay = false;
        leftWidgets = [
          {
            id = "runningApps";
            enabled = true;
            runningAppsCompactMode = true;
            runningAppsGroupByApp = false;
            runningAppsCurrentWorkspace = true;
            runningAppsCurrentMonitor = false;
          }
        ];
        centerWidgets = [ ];
        rightWidgets = [
          {
            id = "cpuUsage";
            enabled = true;
            minimumWidth = true;
          }
          {
            id = "cpuTemp";
            enabled = true;
            minimumWidth = true;
          }
          {
            id = "memUsage";
            enabled = true;
            minimumWidth = true;
            showInGb = true;
            showSwap = false;
          }
          {
            id = "gpuTemp";
            enabled = true;
            selectedGpuIndex = 1;
            pciId = "1002:13c0";
            minimumWidth = true;
          }
          {
            id = "network_speed_monitor";
            enabled = true;
          }
        ];
        spacing = 32;
        innerPadding = 12;
        barLengthPadding = 0;
        bottomGap = 0;
        attachToScreenEdge = true;
        transparency = 1;
        widgetTransparency = 1;
        squareCorners = false;
        noBackground = false;
        gothCornersEnabled = true;
        gothCornerRadiusOverride = true;
        gothCornerRadiusValue = 23;
        borderEnabled = false;
        borderColor = "surfaceText";
        borderOpacity = 1;
        borderThickness = 1;
        widgetOutlineEnabled = false;
        widgetOutlineColor = "primary";
        widgetOutlineOpacity = 1;
        widgetOutlineThickness = 1;
        widgetPadding = 7;
        maximizeWidgetIcons = false;
        maximizeWidgetText = false;
        removeWidgetPadding = false;
        fontScale = 1;
        iconScale = 1;
        autoHide = false;
        autoHideStrict = false;
        autoHideDelay = 250;
        showOnWindowsOpen = false;
        openOnOverview = false;
        visible = true;
        popupGapsAuto = true;
        popupGapsManual = 4;
        maximizeDetection = true;
        useOverlayLayer = false;
        scrollEnabled = true;
        scrollXBehavior = "column";
        scrollYBehavior = "workspace";
        hoverPopouts = false;
        hoverPopoutDelay = 150;
        shadowIntensity = 0;
        shadowOpacity = 60;
        shadowDirectionMode = "inherit";
        shadowDirection = "top";
        shadowColorMode = "default";
        shadowCustomColor = "#000000";
        barInsetPadding = 16;
      }
    ];
  };

  theme = builtins.fromJSON (builtins.readFile ./dank-linux-theme.json);
}
