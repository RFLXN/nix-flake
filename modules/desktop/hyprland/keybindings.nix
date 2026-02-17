{
  terminal ? "kitty",
  launcher ? "rofi -show drun",
  gsrSaveReplayKey ? "ALT, F9",
  terminalKey ? "SUPER, R",
  launcherKey ? "SUPER, D",
  screenshotKey ? "SUPER, S"
}:
{ pkgs, username, ... }: {
  home-manager.users.${username}.wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    bind = [
      # Applications
      "${terminalKey}, exec, ${terminal}"
      "${launcherKey}, exec, ${launcher}"
      "${screenshotKey}, exec, ${pkgs.grimblast}/bin/grimblast copy area"
      "${gsrSaveReplayKey}, exec, gsr-save-replay"

      # Window management
      "$mod, Q, killactive"
      "$mod, M, exit"
      "$mod, V, togglefloating"
      "$mod, F, fullscreen"
      "$mod, P, pseudo"
      "$mod, J, togglesplit"

      # Show minimized windows
      "$mod, Z, togglespecialworkspace, minimized"

      # Focus movement
      "$mod, left, movefocus, l"
      "$mod, right, movefocus, r"
      "$mod, up, movefocus, u"
      "$mod, down, movefocus, d"
    ];

    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];
  };
}
