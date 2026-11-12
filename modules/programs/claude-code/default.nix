{ }:
{ pkgs, claude-code, username, ... }:
let
  # Pinned: the status line command runs on every render, and "@latest" would
  # re-resolve against the npm registry and run whatever was published last.
  claudePowerlineVersion = "1.16.1";
  claude-powerline-wrapper = pkgs.writeShellScript "claude-powerline" ''
    export PATH="${pkgs.nodejs_22}/bin:$PATH"
    exec ${pkgs.nodejs_22}/bin/npx -y @owloops/claude-powerline@${claudePowerlineVersion} --style=powerline --theme=tokyo-night
  '';
in {
  nixpkgs.overlays = [ claude-code.overlays.default ];
  environment.systemPackages = [ pkgs.claude-code ];

  home-manager.users.${username} = {
    programs.claude-code = {
      enable = true;
      # Keep ~/.claude/settings.json a writable file that the declared settings
      # are merged into, so Claude Code can save its own user-scope settings.
      mutableSettings = true;
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