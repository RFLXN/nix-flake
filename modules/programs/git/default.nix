{ name, email }:
{ username, ... }: {
  home-manager.users.${username} = {
    programs.git = {
      enable = true;
      lfs.enable = true;

      ignores = [
        ".idea"
        ".DS_Store"
      ];

      settings = {
        user = {
          inherit name email;
        };

        init.defaultBranch = "main";
      };
    };

    programs.gh = {
      enable = true;
      gitCredentialHelper.enable = true;
    };
  };
}
