{ createDirectories ? true }:
{ username, ... }: {
  home-manager.users.${username}.xdg.userDirs = {
    enable = true;
    inherit createDirectories;
    setSessionVariables = true;

    desktop = "/home/${username}/Desktop";
    documents = "/home/${username}/Documents";
    download = "/home/${username}/Downloads";
    music = "/home/${username}/Music";
    pictures = "/home/${username}/Pictures";
    videos = "/home/${username}/Videos";

    publicShare = null;
    templates = null;
  };
}
