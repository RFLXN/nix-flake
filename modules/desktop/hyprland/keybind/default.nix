{
  useDefaults = { mod ? "SUPER", subMod ? "SUPER SHIFT" }:
    { pkgs, username, ... }:
    let
      hyprSmartStep = pkgs.writeShellScriptBin "hypr-smart-step" ''
        set -euo pipefail

        mode="''${1:-}"
        direction="''${2:-}"

        hyprctl='${pkgs.hyprland}/bin/hyprctl'
        jq='${pkgs.jq}/bin/jq'

        active_window_json="$("$hyprctl" -j activewindow 2>/dev/null || true)"
        if [ -z "$active_window_json" ] || [ "$active_window_json" = "null" ]; then
          exit 0
        fi

        focused_monitor_json="$("$hyprctl" -j monitors | "$jq" -c '.[] | select(.focused == true)' | head -n 1)"
        if [ -z "$focused_monitor_json" ]; then
          exit 0
        fi

        width="$(printf '%s' "$focused_monitor_json" | "$jq" -r '.width // 0')"
        height="$(printf '%s' "$focused_monitor_json" | "$jq" -r '.height // 0')"

        step_x=$((width * 5 / 100))
        step_y=$((height * 5 / 100))
        [ "$step_x" -lt 1 ] && step_x=1
        [ "$step_y" -lt 1 ] && step_y=1

        case "$direction" in
          left)
            dx=$((-step_x))
            dy=0
            swap_dir="l"
            ;;
          right)
            dx=$step_x
            dy=0
            swap_dir="r"
            ;;
          up)
            dx=0
            dy=$((-step_y))
            swap_dir="u"
            ;;
          down)
            dx=0
            dy=$step_y
            swap_dir="d"
            ;;
          *)
            exit 2
            ;;
        esac

        case "$mode" in
          resize)
            before_w="$(printf '%s' "$active_window_json" | "$jq" -r '.size[0] // 0')"
            before_h="$(printf '%s' "$active_window_json" | "$jq" -r '.size[1] // 0')"

            "$hyprctl" dispatch resizeactive "$dx" "$dy" >/dev/null

            after_window_json="$("$hyprctl" -j activewindow 2>/dev/null || true)"
            after_w="$(printf '%s' "$after_window_json" | "$jq" -r '.size[0] // 0')"
            after_h="$(printf '%s' "$after_window_json" | "$jq" -r '.size[1] // 0')"
            floating="$(printf '%s' "$after_window_json" | "$jq" -r '.floating // false')"

            # Dwindle can no-op for some tiled directions; fallback to splitratio.
            if [ "$floating" != "true" ] && [ "$before_w" = "$after_w" ] && [ "$before_h" = "$after_h" ]; then
              case "$direction" in
                left|up)
                  "$hyprctl" dispatch splitratio -0.05 >/dev/null
                  ;;
                right|down)
                  "$hyprctl" dispatch splitratio 0.05 >/dev/null
                  ;;
              esac
            fi
            ;;
          swap-or-move)
            floating="$(printf '%s' "$active_window_json" | "$jq" -r '.floating // false')"
            if [ "$floating" = "true" ]; then
              "$hyprctl" dispatch moveactive "$dx" "$dy" >/dev/null
            else
              "$hyprctl" dispatch swapwindow "$swap_dir" >/dev/null
            fi
            ;;
          *)
            exit 2
            ;;
        esac
      '';
    in
    {
      home-manager.users.${username} = {
        home.packages = [ hyprSmartStep ];

        wayland.windowManager.hyprland.settings = {
          "$mod" = "${mod}";
          "$submod" = "${subMod}";
          "$mleft" = "mouse:272";
          "$mright" = "mouse:273";
          "$mwheel" = "mouse:274";

          bind = [
            # Window management
            "$mod, Q, killactive"
            "$mod, V, togglefloating"
            "$mod, J, togglesplit"
            "$mod, F, fullscreen"

            # Workspace navigation
            "$mod, bracketleft, workspace, m-1"
            "$mod, bracketright, workspace, m+1"
            "$mod, 1, workspace, 1"
            "$mod, 2, workspace, 2"
            "$mod, 3, workspace, 3"
            "$mod, 4, workspace, 4"
            "$mod, 5, workspace, 5"

            # Move current window to workspace
            "$submod, bracketleft, movetoworkspacesilent, m-1"
            "$submod, bracketright, movetoworkspacesilent, m+1"
            "$submod, 1, movetoworkspacesilent, 1"
            "$submod, 2, movetoworkspacesilent, 2"
            "$submod, 3, movetoworkspacesilent, 3"
            "$submod, 4, movetoworkspacesilent, 4"
            "$submod, 5, movetoworkspacesilent, 5"

            # 5% directional resize
            "$mod, left, exec, ${hyprSmartStep}/bin/hypr-smart-step resize left"
            "$mod, right, exec, ${hyprSmartStep}/bin/hypr-smart-step resize right"
            "$mod, up, exec, ${hyprSmartStep}/bin/hypr-smart-step resize up"
            "$mod, down, exec, ${hyprSmartStep}/bin/hypr-smart-step resize down"

            # Tiled: swap direction. Floating: move by 5%.
            "$submod, left, exec, ${hyprSmartStep}/bin/hypr-smart-step swap-or-move left"
            "$submod, right, exec, ${hyprSmartStep}/bin/hypr-smart-step swap-or-move right"
            "$submod, up, exec, ${hyprSmartStep}/bin/hypr-smart-step swap-or-move up"
            "$submod, down, exec, ${hyprSmartStep}/bin/hypr-smart-step swap-or-move down"
          ];

          bindm = [
            "$mod, $mleft, movewindow"
            "$mod, $mright, resizewindow"
          ];
        };
      };
    };
  
  useKitty = import ./kitty.nix;
  useGsrSaveReplay = import ./gsr-save-replay.nix;
  useAgsLauncher = import ./ags-launcher.nix;
  useAgsRestart = import ./ags-restart.nix;
  useRofi = import ./rofi.nix;
  usePrintscreen = import ./printscreen.nix;
  useSpectacle = import ./spectacle.nix;
}
