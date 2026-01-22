{ username, ... }: {
  users.mutableUsers = false;
  users.users.${username} = {
    isNormalUser = true;
    home = "/home/${username}";
    extraGroups = [ "wheel" "docker" ];
    hashedPasswordFile = "/home/${username}/secrets/${username}.hashedPassword";
  };
}