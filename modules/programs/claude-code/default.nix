{ }:
{ nixpkgs, pkgs, lib, claude-code, username, ... }:
let
  claude-powerline-wrapper = pkgs.writeShellScript "claude-powerline" ''
    export PATH="${pkgs.nodejs_22}/bin:$PATH"
    exec ${pkgs.nodejs_22}/bin/npx -y @owloops/claude-powerline@latest --style=powerline --theme=tokyo-night
  '';
in {
  nixpkgs.overlays = [ claude-code.overlays.default ];
  environment.systemPackages = [ pkgs.claude-code ];

  home-manager.users.${username} = {
    programs.claude-code = {
      enable = true;
      settings = {
        statusLine = {
          type = "command";
          padding = 0;
          command = "${claude-powerline-wrapper}";
        };
      };
    };

    home.file.".claude/claude-powerline.json".source = ./claude-powerline.json;
  };
}