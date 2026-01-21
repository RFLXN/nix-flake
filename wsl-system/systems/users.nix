{ username, ... }: {
  users.mutableUsers = false;
  users.users.${username} = {
    isNormalUser = true;
    home = "/home/${username}";
    extraGroups = [ "wheel" "docker" ];
    hashedPasswordFile = "/persist/secrets/${username}.hashedPassword";
  };
}