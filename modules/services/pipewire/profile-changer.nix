{
  profiles,
  defaultProfile ? null,
}:
{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  normalizeDeviceProfile =
    {
      device,
      profile,
      required ? false,
    }:
    {
      inherit device profile required;
    };

  normalizeProfile =
    {
      name,
      label ? name,
      description ? label,
      icon ? "audio-card",
      rate ? null,
      quantum ? null,
      deviceProfiles ? [ ],
      startUserServices ? [ ],
      stopUserServices ? [ ],
    }:
    {
      inherit
        name
        label
        description
        icon
        rate
        quantum
        startUserServices
        stopUserServices
        ;
      deviceProfiles = map normalizeDeviceProfile deviceProfiles;
    };

  normalizedProfiles = map normalizeProfile profiles;
  profileNames = map (profile: profile.name) normalizedProfiles;
  resolvedDefaultProfile =
    if defaultProfile != null then
      defaultProfile
    else if normalizedProfiles != [ ] then
      (builtins.head normalizedProfiles).name
    else
      null;

  profileConfig = pkgs.writeText "pipewire-profile-changer.json" (
    builtins.toJSON {
      version = 1;
      defaultProfile = resolvedDefaultProfile;
      profiles = normalizedProfiles;
      pollIntervalSeconds = 2;
      tools = {
        notifySend = lib.getExe' pkgs.libnotify "notify-send";
        pwDump = lib.getExe' pkgs.pipewire "pw-dump";
        pwMetadata = lib.getExe' pkgs.pipewire "pw-metadata";
        systemctl = lib.getExe' pkgs.systemd "systemctl";
        wpctl = lib.getExe' pkgs.wireplumber "wpctl";
      };
    }
  );

  python = pkgs.python3.withPackages (pythonPackages: [ pythonPackages.pygobject3 ]);
  giPackages = [
    pkgs.glib.out
    pkgs.gobject-introspection-unwrapped
    pkgs.gtk3
    pkgs.gdk-pixbuf
    pkgs.pango.out
    pkgs.harfbuzz
    pkgs.atk
    pkgs.libayatana-appindicator
  ];
  giTypelibPath = lib.makeSearchPath "lib/girepository-1.0" giPackages;
  libraryPath = lib.makeLibraryPath giPackages;
  dataPath = lib.makeSearchPath "share" [
    pkgs.gtk3
    pkgs.adwaita-icon-theme
    pkgs.hicolor-icon-theme
  ];

  profileChanger = pkgs.writeShellApplication {
    name = "pipewire-profile";
    text = ''
      export GI_TYPELIB_PATH="${giTypelibPath}''${GI_TYPELIB_PATH:+:$GI_TYPELIB_PATH}"
      export LD_LIBRARY_PATH="${libraryPath}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      export XDG_DATA_DIRS="${dataPath}''${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"

      exec ${lib.getExe python} ${./profile-changer.py} --config ${profileConfig} "$@"
    '';
  };

  validProfileName =
    name: lib.isString name && builtins.match "^[A-Za-z0-9][A-Za-z0-9._-]*$" name != null;
  validServiceList =
    services: lib.isList services && lib.all (service: lib.isString service && service != "") services;
  validDeviceProfile =
    deviceProfile:
    lib.isString deviceProfile.device
    && deviceProfile.device != ""
    && lib.isString deviceProfile.profile
    && deviceProfile.profile != ""
    && lib.isBool deviceProfile.required;
  validProfile =
    profile:
    validProfileName profile.name
    && lib.isString profile.label
    && profile.label != ""
    && lib.isString profile.description
    && lib.isString profile.icon
    && profile.icon != ""
    && (profile.rate == null || (lib.isInt profile.rate && profile.rate > 0))
    && (profile.quantum == null || (lib.isInt profile.quantum && profile.quantum > 0))
    && lib.isList profile.deviceProfiles
    && lib.all validDeviceProfile profile.deviceProfiles
    && validServiceList profile.startUserServices
    && validServiceList profile.stopUserServices
    && lib.intersectLists profile.startUserServices profile.stopUserServices == [ ];
in
{
  assertions = [
    {
      assertion = config.services.pipewire.enable;
      message = "pipewire.useProfileChanger requires services.pipewire.enable.";
    }
    {
      assertion = normalizedProfiles != [ ];
      message = "pipewire.useProfileChanger: profiles must not be empty.";
    }
    {
      assertion = lib.all validProfile normalizedProfiles;
      message = "pipewire.useProfileChanger: every profile must have valid metadata, clock values, device profiles, and disjoint user-service lists.";
    }
    {
      assertion = builtins.length profileNames == builtins.length (lib.unique profileNames);
      message = "pipewire.useProfileChanger: profile names must be unique.";
    }
    {
      assertion = resolvedDefaultProfile != null && builtins.elem resolvedDefaultProfile profileNames;
      message = "pipewire.useProfileChanger: defaultProfile must name one of the configured profiles.";
    }
  ];

  home-manager.users.${username} = {
    home.packages = [ profileChanger ];

    systemd.user.services.pipewire-profile-changer = {
      Unit = {
        Description = "PipeWire Profile Changer";
        After = [
          "graphical-session.target"
          "pipewire.service"
          "wireplumber.service"
        ];
        PartOf = [
          "graphical-session.target"
          "pipewire.service"
          "wireplumber.service"
        ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${profileChanger}/bin/pipewire-profile tray";
        Restart = "on-failure";
        RestartSec = 2;
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
