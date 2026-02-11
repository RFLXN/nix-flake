{
  usePlasma6 = { overrideConfig ? false, excludePackages ? [], enableSddmIntegration ? true, persistPath ? null }:
    { lib, pkgs, plasma-manager, username, defaultPersistPath ? null, ... }:
    let
      path = if persistPath != null then persistPath else defaultPersistPath;
    in
    lib.mkMerge [
      {
        services.xserver.enable = true;
        services.desktopManager.plasma6.enable = true;

        environment.plasma6.excludePackages = excludePackages;

        home-manager.sharedModules = [
          plasma-manager.homeModules.plasma-manager
        ];

        home-manager.users.${username}.programs.plasma = {
          enable = true;
          inherit overrideConfig;
        };
      }
      (lib.mkIf enableSddmIntegration {
        environment.systemPackages = [ pkgs.kdePackages.sddm-kcm ];
      })
      (lib.mkIf (enableSddmIntegration && path != null) {
        environment.persistence.${path}.directories = [ "/var/lib/sddm" ];
      })
    ];

  theme = import ./theme;
  kwin = import ./kwin;
  shortcuts = import ./shortcuts;
}
