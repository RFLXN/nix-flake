{
  batteryChargeLimit ? null,
  lockScreenPasswordField ? null,
  package ? null,
  session ? { },
  settings ? { },
  systemdTarget ? null,
  theme ? null,
}:
{
  dank-material-shell,
  lib,
  pkgs,
  username,
  ...
}:
let
  baseDmsPackage =
    if package != null then
      package
    else
      dank-material-shell.packages.${pkgs.stdenv.hostPlatform.system}.default;

  isNumber = value: builtins.isInt value || builtins.isFloat value;

  passwordField =
    if lockScreenPasswordField == null then
      null
    else
      {
        width = 380;
        height = 60;
        radius = 18;
        backgroundColor = "#181818";
        backgroundOpacity = 0.9;
        borderColor = "#ffffff";
        focusBorderColor = "#ffffff";
        showLockIcon = true;
      }
      // (if builtins.isAttrs lockScreenPasswordField then lockScreenPasswordField else { });

  passwordFieldAssertions =
    if passwordField == null then
      true
    else
      lib.assertMsg (builtins.isAttrs lockScreenPasswordField)
        "hyprland.useDankLinux: lockScreenPasswordField must be an attribute set"
      && lib.assertMsg (isNumber passwordField.width && passwordField.width > 0)
        "hyprland.useDankLinux: lockScreenPasswordField.width must be a positive number"
      && lib.assertMsg (isNumber passwordField.height && passwordField.height > 0)
        "hyprland.useDankLinux: lockScreenPasswordField.height must be a positive number"
      && lib.assertMsg (isNumber passwordField.radius && passwordField.radius >= 0)
        "hyprland.useDankLinux: lockScreenPasswordField.radius must be a non-negative number"
      && lib.assertMsg (
        isNumber passwordField.backgroundOpacity
        && passwordField.backgroundOpacity >= 0
        && passwordField.backgroundOpacity <= 1
      ) "hyprland.useDankLinux: lockScreenPasswordField.backgroundOpacity must be between 0 and 1"
      && lib.assertMsg (builtins.isString passwordField.backgroundColor)
        "hyprland.useDankLinux: lockScreenPasswordField.backgroundColor must be a string"
      && lib.assertMsg (builtins.isString passwordField.borderColor)
        "hyprland.useDankLinux: lockScreenPasswordField.borderColor must be a string"
      && lib.assertMsg (builtins.isString passwordField.focusBorderColor)
        "hyprland.useDankLinux: lockScreenPasswordField.focusBorderColor must be a string"
      && lib.assertMsg (builtins.isBool passwordField.showLockIcon)
        "hyprland.useDankLinux: lockScreenPasswordField.showLockIcon must be a boolean";

  batteryChargeHelper = pkgs.writeScript "dms-battery-charge-limit" (
    "#!${pkgs.python3}/bin/python3\n" + builtins.readFile ./battery-charge-limit.py
  );

  dmsPackage =
    assert passwordFieldAssertions;
    if passwordField == null then
      baseDmsPackage
    else
      baseDmsPackage.overrideAttrs (oldAttrs: {
        postInstall = (oldAttrs.postInstall or "") + ''
          # DMS 1.7 split authentication out of LockScreenContent.qml.
          lockAuthWidget="$out/share/quickshell/dms/Modules/Lock/Widgets/LockAuthWidget.qml"
          chmod u+w "$lockAuthWidget"

          substituteInPlace "$lockAuthWidget" \
            --replace-fail 'LockMetrics.passwordRowWidth' ${lib.escapeShellArg (toString passwordField.width)} \
            --replace-fail 'LockMetrics.fieldHeight' ${lib.escapeShellArg (toString passwordField.height)} \
            --replace-fail 'radius: root.style === "expressive" ? Theme.cornerRadiusXL : Theme.fullRadius(width, height)' \
              ${lib.escapeShellArg "radius: ${toString passwordField.radius}"} \
            --replace-fail 'return root.style === "expressive" ? Theme.surfaceContainerHigh : Theme.cardSurface;' \
              ${lib.escapeShellArg "return Theme.withAlpha(${builtins.toJSON passwordField.backgroundColor}, ${toString passwordField.backgroundOpacity});"} \
            --replace-fail 'border.color: focusRingShown ? Theme.focusRingColor : Theme.outlineMedium' \
              ${lib.escapeShellArg "border.color: passwordField.activeFocus ? ${builtins.toJSON passwordField.focusBorderColor} : ${builtins.toJSON passwordField.borderColor}"} \
            --replace-fail 'visible: !root.dots && !root.ring && !root.minimal' \
              ${lib.escapeShellArg "visible: ${lib.boolToString passwordField.showLockIcon} && !root.dots && !root.ring && !root.minimal"}
        '';
      });

  themeId =
    if theme == null then
      null
    else
      theme.id or (throw "hyprland.useDankLinux: theme.id is required when theme is set");

  themeConfigPath = "DankMaterialShell/themes/${themeId}/theme.json";
in
{
  assertions = [
    {
      assertion = batteryChargeLimit == null || (
        lib.isInt batteryChargeLimit && batteryChargeLimit >= 50 && batteryChargeLimit <= 100
      );
      message = "hyprland.useDankLinux: batteryChargeLimit must be null or an integer between 50 and 100.";
    }
  ];

  # One Nix value configures both the DMS UI and the hardware. A changed
  # ExecStart restarts this oneshot during nixos-rebuild switch.
  systemd.services.dms-battery-charge-limit = lib.mkIf (batteryChargeLimit != null) {
    description = "Apply and verify the declarative DMS battery charge limit";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-udev-trigger.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${batteryChargeHelper} --limit ${toString batteryChargeLimit}";
    };
  };

  home-manager.users.${username} = {
    imports = [ dank-material-shell.homeModules.dank-material-shell ];

    programs.dank-material-shell = {
      enable = true;
      package = dmsPackage;
      inherit session;
      settings = settings // lib.optionalAttrs (batteryChargeLimit != null) {
        inherit batteryChargeLimit;
      } // lib.optionalAttrs (theme != null) {
        currentThemeName = "custom";
        customThemeFile = "/home/${username}/.config/${themeConfigPath}";
      };
      systemd = {
        enable = true;
      }
      // lib.optionalAttrs (systemdTarget != null) {
        target = systemdTarget;
      };
    };

    xdg.configFile =
      lib.optionalAttrs (settings != { } || batteryChargeLimit != null) {
        "DankMaterialShell/settings.json".force = true;
      }
      // lib.optionalAttrs (theme != null) {
        ${themeConfigPath} = {
          force = true;
          text = builtins.toJSON theme;
        };
      };

    xdg.stateFile = lib.optionalAttrs (session != { }) {
      "DankMaterialShell/session.json".force = true;
    };

    systemd.user.services.dms.Service.Environment = [ "DMS_DISABLE_POLKIT=1" ];
  };
}
