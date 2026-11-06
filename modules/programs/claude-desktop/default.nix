# Claude Desktop for Linux, repackaged by aaddrick/claude-desktop-debian
# from Anthropic's official .deb.
#
# `withFhs` installs the FHS-wrapped variant (upstream's default package),
# which provides node, uv, docker, and similar tools so MCP servers can run.
# App state lives in ~/.config/Claude under the persisted /home.
{
  withFhs ? true,
  enableWayland ? false,
}:
{ lib, pkgs, claude-desktop, ... }:
{
  assertions = [
    {
      assertion = lib.isBool withFhs;
      message = "programs.useClaudeDesktop: withFhs must be a boolean.";
    }
    {
      assertion = lib.isBool enableWayland;
      message = "programs.useClaudeDesktop: enableWayland must be a boolean.";
    }
  ];

  nixpkgs.overlays = [ claude-desktop.overlays.default ];

  environment.systemPackages = [
    (if withFhs then pkgs.claude-desktop-fhs else pkgs.claude-desktop)
  ];

  # Opt-in native Wayland, read by the upstream launcher.
  environment.sessionVariables = lib.mkIf enableWayland {
    CLAUDE_USE_WAYLAND = "1";
  };
}
