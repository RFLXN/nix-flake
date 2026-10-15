{ initialClass, processArgv0, initialTitle ? "", workspace ? "hidden" }:
{ hyprLua, lib, username, ... }:
let
  tag = "hidden-${workspace}";
in
{
  assertions = [
    {
      assertion = builtins.isString initialClass && initialClass != ""
        && builtins.isString initialTitle
        && builtins.isString processArgv0 && processArgv0 != "";
      message = "hyprland.windowRules.useHidden: initialClass and processArgv0 must be non-empty strings, and initialTitle must be a string.";
    }
    {
      assertion = builtins.isString workspace && builtins.match "[A-Za-z0-9_-]+" workspace != null;
      message = "hyprland.windowRules.useHidden: workspace must be a non-empty special workspace name (letters, digits, underscores or hyphens, without special:).";
    }
  ];

  home-manager.users.${username}.wayland.windowManager.hyprland = {
    extraConfig = lib.mkAfter ''
      do
        local setup = (function()
          ${builtins.readFile ./hidden.lua}
        end)()
        setup(${hyprLua.toLua { inherit initialClass initialTitle processArgv0 workspace tag; }})
      end
    '';

    settings.window_rule = lib.mkAfter [
      {
        # Tag matchers use literal tag names, not regular expressions.
        match.tag = tag;
        no_focus = true;
        focus_on_activate = false;

        # Remain invisible even if the special workspace is explicitly opened.
        opacity = "0 override 0 override 0 override";
        no_anim = true;
        no_blur = true;
        no_shadow = true;
        dim_around = false;
        decorate = false;
        border_size = 0;
      }
    ];
  };
}
