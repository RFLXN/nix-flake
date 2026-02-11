{ stateVersion ? "25.11", backupCommand ? null }:
{ pkgs, lib, username, home-manager, ... }: {
  imports = [ home-manager.nixosModules.home-manager ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    backupFileExtension = lib.mkIf (backupCommand == null) "backup";
    inherit backupCommand;

    users.${username} = {
      home.stateVersion = stateVersion;
      programs.home-manager.enable = true;
    };
  };
}
