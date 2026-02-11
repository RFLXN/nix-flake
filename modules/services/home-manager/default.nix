{ stateVersion ? "25.11" }:
{ pkgs, username, home-manager, ... }: {
  imports = [ home-manager.nixosModules.home-manager ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    backupFileExtension = "backup";

    users.${username} = {
      home.stateVersion = stateVersion;
      programs.home-manager.enable = true;
    };
  };
}
