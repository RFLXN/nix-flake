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
          name = "RFLXN";
          email = "solid2113@naver.com";
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