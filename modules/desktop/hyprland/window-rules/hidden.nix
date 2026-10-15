{ match, workspace ? "hidden" }:
{ lib, username, ... }:
{
  assertions = [
    {
      assertion = builtins.isAttrs match && match != { };
      message = "hyprland.windowRules.useHidden: match must be a non-empty window-rule match attribute set.";
    }
    {
      assertion = builtins.isString workspace && builtins.match "[A-Za-z0-9_-]+" workspace != null;
      message = "hyprland.windowRules.useHidden: workspace must be a non-empty special workspace name (letters, digits, underscores or hyphens, without special:).";
    }
  ];

  home-manager.users.${username}.wayland.windowManager.hyprland.settings.window_rule = lib.mkAfter [
    {
      inherit match;
      workspace = "special:${workspace} silent";
      no_initial_focus = true;
      no_focus = true;
      focus_on_activate = false;
      suppress_event = "activate activatefocus fullscreen maximize fullscreenoutput";

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
}
