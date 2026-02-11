{
  useShell = { }:
    { pkgs, ... }: {
      environment.shells = [ pkgs.bash ];

      environment.variables = {
        EDITOR = "nano";
      };
    };

  useZsh = import ./zsh;
}
