{
  useDefaults = { mod ? "SUPER", subMod ? "SUPER SHIFT" }:
    { hyprLua, pkgs, username, ... }:
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

            "$hyprctl" dispatch "hl.dsp.window.resize({ x = $dx, y = $dy, relative = true })" >/dev/null

            after_window_json="$("$hyprctl" -j activewindow 2>/dev/null || true)"
            after_w="$(printf '%s' "$after_window_json" | "$jq" -r '.size[0] // 0')"
            after_h="$(printf '%s' "$after_window_json" | "$jq" -r '.size[1] // 0')"
            floating="$(printf '%s' "$after_window_json" | "$jq" -r '.floating // false')"

            # Dwindle can no-op for some tiled directions; fallback to splitratio.
            if [ "$floating" != "true" ] && [ "$before_w" = "$after_w" ] && [ "$before_h" = "$after_h" ]; then
              case "$direction" in
                left|up)
                  "$hyprctl" dispatch 'hl.dsp.layout("splitratio -0.05")' >/dev/null
                  ;;
                right|down)
                  "$hyprctl" dispatch 'hl.dsp.layout("splitratio 0.05")' >/dev/null
                  ;;
              esac
            fi
            ;;
          swap-or-move)
            floating="$(printf '%s' "$active_window_json" | "$jq" -r '.floating // false')"
            if [ "$floating" = "true" ]; then
              "$hyprctl" dispatch "hl.dsp.window.move({ x = $dx, y = $dy, relative = true })" >/dev/null
            else
              "$hyprctl" dispatch "hl.dsp.window.swap({ direction = \"$swap_dir\" })" >/dev/null
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

        wayland.windowManager.hyprland.settings.bind = [
          # Window management
          (hyprLua.bind "${mod}, Q" "hl.dsp.window.close()")
          (hyprLua.bind "${mod}, V" ''hl.dsp.window.float({ action = "toggle" })'')
          (hyprLua.bind "${mod}, F" "hl.dsp.window.fullscreen()")
          (hyprLua.bind "${mod}, mouse_down" ''hl.dsp.layout("move -col")'')
          (hyprLua.bind "${mod}, mouse_up" ''hl.dsp.layout("move +col")'')

          # Workspace navigation
          (hyprLua.bind "${mod}, bracketleft" ''hl.dsp.focus({ workspace = "m-1" })'')
          (hyprLua.bind "${mod}, bracketright" ''hl.dsp.focus({ workspace = "m+1" })'')
          (hyprLua.bind "${mod}, 1" ''hl.dsp.focus({ workspace = "1" })'')
          (hyprLua.bind "${mod}, 2" ''hl.dsp.focus({ workspace = "2" })'')
          (hyprLua.bind "${mod}, 3" ''hl.dsp.focus({ workspace = "3" })'')
          (hyprLua.bind "${mod}, 4" ''hl.dsp.focus({ workspace = "4" })'')
          (hyprLua.bind "${mod}, 5" ''hl.dsp.focus({ workspace = "5" })'')
          (hyprLua.bind "${mod}, 6" ''hl.dsp.focus({ workspace = "6" })'')
          (hyprLua.bind "${mod}, 7" ''hl.dsp.focus({ workspace = "7" })'')

          # Move current window to workspace
          (hyprLua.bind "${subMod}, bracketleft" ''hl.dsp.window.move({ workspace = "m-1", follow = false })'')
          (hyprLua.bind "${subMod}, bracketright" ''hl.dsp.window.move({ workspace = "m+1", follow = false })'')
          (hyprLua.bind "${subMod}, 1" ''hl.dsp.window.move({ workspace = "1", follow = false })'')
          (hyprLua.bind "${subMod}, 2" ''hl.dsp.window.move({ workspace = "2", follow = false })'')
          (hyprLua.bind "${subMod}, 3" ''hl.dsp.window.move({ workspace = "3", follow = false })'')
          (hyprLua.bind "${subMod}, 4" ''hl.dsp.window.move({ workspace = "4", follow = false })'')
          (hyprLua.bind "${subMod}, 5" ''hl.dsp.window.move({ workspace = "5", follow = false })'')
          (hyprLua.bind "${subMod}, 6" ''hl.dsp.window.move({ workspace = "6", follow = false })'')
          (hyprLua.bind "${subMod}, 7" ''hl.dsp.window.move({ workspace = "7", follow = false })'')
          (hyprLua.bind "${subMod}, 8" ''hl.dsp.window.move({ workspace = "8", follow = false })'')

          # Repeat while the key is held.
          (hyprLua.execBindWith "${mod}, left" "${hyprSmartStep}/bin/hypr-smart-step resize left" { repeating = true; })
          (hyprLua.execBindWith "${mod}, right" "${hyprSmartStep}/bin/hypr-smart-step resize right" { repeating = true; })
          (hyprLua.execBindWith "${mod}, up" "${hyprSmartStep}/bin/hypr-smart-step resize up" { repeating = true; })
          (hyprLua.execBindWith "${mod}, down" "${hyprSmartStep}/bin/hypr-smart-step resize down" { repeating = true; })

          # Tiled: swap direction. Floating: move by 5%.
          (hyprLua.execBindWith "${subMod}, left" "${hyprSmartStep}/bin/hypr-smart-step swap-or-move left" { repeating = true; })
          (hyprLua.execBindWith "${subMod}, right" "${hyprSmartStep}/bin/hypr-smart-step swap-or-move right" { repeating = true; })
          (hyprLua.execBindWith "${subMod}, up" "${hyprSmartStep}/bin/hypr-smart-step swap-or-move up" { repeating = true; })
          (hyprLua.execBindWith "${subMod}, down" "${hyprSmartStep}/bin/hypr-smart-step swap-or-move down" { repeating = true; })

          # Mouse movement and resize.
          (hyprLua.bindWith "${mod}, mouse:272" "hl.dsp.window.drag()" { mouse = true; })
          (hyprLua.bindWith "${mod}, mouse:273" "hl.dsp.window.resize()" { mouse = true; })
        ];
      };
    };
  
  useAgsLauncher = import ./ags-launcher.nix;
  useAgsRestart = import ./ags-restart.nix;
  useKitty = import ./kitty.nix;
  useGsrSaveReplay = import ./gsr-save-replay.nix;
  useScreenOff = import ./screen-off.nix;
  useHyprshot = import ./hyprshot.nix;
  useToggleMonitorSetup = import ./toggle-monitor-setup.nix;
}
