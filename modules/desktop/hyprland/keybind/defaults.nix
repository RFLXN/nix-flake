{
  mod ? "SUPER",
  subMod ? "SUPER SHIFT",
  # Number keys bound to "focus workspace N" and "move window to workspace N".
  workspaceCount ? 7,
  moveWorkspaceCount ? workspaceCount,
}:
{ config, hyprLua, lib, pkgs, username, ... }:
let
  hyprSmartStep = pkgs.writeShellScriptBin "hypr-smart-step" ''
    set -euo pipefail

    mode="''${1:-}"
    direction="''${2:-}"

    hyprctl='${config.programs.hyprland.package}/bin/hyprctl'
    jq='${pkgs.jq}/bin/jq'

    active_window_json="$("$hyprctl" -j activewindow 2>/dev/null || true)"
    if [ -z "$active_window_json" ] || [ "$active_window_json" = "null" ]; then
      exit 0
    fi

    focused_monitor_json="$("$hyprctl" -j monitors | "$jq" -c '.[] | select(.focused == true)' | head -n 1)"
    if [ -z "$focused_monitor_json" ]; then
      exit 0
    fi

    # hyprctl reports the raw mode size. Convert it to what is on screen:
    # swap the axes for 90/270 degree transforms and divide by the scale.
    read -r width height < <(printf '%s' "$focused_monitor_json" | "$jq" -r '
      (if (.scale // 1) > 0 then (.scale // 1) else 1 end) as $scale
      | (if ((.transform // 0) % 2) == 1 then [.height, .width] else [.width, .height] end)
      | map((. // 0) / $scale | floor)
      | @tsv
    ')

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

        # Dwindle can no-op for some tiled directions; fall back to splitratio.
        # splitratio is a dwindle-only layout message, so skip other layouts.
        if [ "$floating" != "true" ] && [ "$before_w" = "$after_w" ] && [ "$before_h" = "$after_h" ]; then
          layout="$("$hyprctl" -j activeworkspace 2>/dev/null | "$jq" -r '.tiledLayout // ""' || true)"
          if [ "$layout" = "dwindle" ]; then
            case "$direction" in
              left|up)
                "$hyprctl" dispatch 'hl.dsp.layout("splitratio -0.05")' >/dev/null
                ;;
              right|down)
                "$hyprctl" dispatch 'hl.dsp.layout("splitratio 0.05")' >/dev/null
                ;;
            esac
          fi
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

  smartStep = "${hyprSmartStep}/bin/hypr-smart-step";
  directions = [ "left" "right" "up" "down" ];
  workspaceNames = count: map toString (lib.range 1 count);

  # Repeat while the key is held.
  stepBinds = keyMod: action: map (
    direction:
    hyprLua.execBindWith "${keyMod}, ${direction}" "${smartStep} ${action} ${direction}" { repeating = true; }
  ) directions;
in
{
  assertions = [
    {
      assertion =
        lib.isInt workspaceCount && workspaceCount >= 0 && workspaceCount <= 9
        && lib.isInt moveWorkspaceCount && moveWorkspaceCount >= 0 && moveWorkspaceCount <= 9;
      message = "hyprland.keybinds.useDefaults: workspaceCount and moveWorkspaceCount must be integers from 0 to 9.";
    }
  ];

  home-manager.users.${username} = {
    home.packages = [ hyprSmartStep ];

    wayland.windowManager.hyprland.settings.bind =
      [
        # Window management
        (hyprLua.bind "${mod}, Q" "hl.dsp.window.close()")
        (hyprLua.bind "${mod}, V" ''hl.dsp.window.float({ action = "toggle" })'')
        (hyprLua.bind "${mod}, F" "hl.dsp.window.fullscreen()")
        # Column movement; only meaningful on scrolling-layout workspaces.
        (hyprLua.bind "${mod}, mouse_down" ''hl.dsp.layout("move -col")'')
        (hyprLua.bind "${mod}, mouse_up" ''hl.dsp.layout("move +col")'')

        # Workspace navigation
        (hyprLua.bind "${mod}, bracketleft" ''hl.dsp.focus({ workspace = "m-1" })'')
        (hyprLua.bind "${mod}, bracketright" ''hl.dsp.focus({ workspace = "m+1" })'')
      ]
      ++ map (
        name: hyprLua.bind "${mod}, ${name}" ''hl.dsp.focus({ workspace = "${name}" })''
      ) (workspaceNames workspaceCount)
      ++ [
        # Move current window to workspace
        (hyprLua.bind "${subMod}, bracketleft" ''hl.dsp.window.move({ workspace = "m-1", follow = false })'')
        (hyprLua.bind "${subMod}, bracketright" ''hl.dsp.window.move({ workspace = "m+1", follow = false })'')
      ]
      ++ map (
        name:
        hyprLua.bind "${subMod}, ${name}" ''hl.dsp.window.move({ workspace = "${name}", follow = false })''
      ) (workspaceNames moveWorkspaceCount)
      # Resize the active window.
      ++ stepBinds mod "resize"
      # Tiled: swap direction. Floating: move by 5%.
      ++ stepBinds subMod "swap-or-move"
      ++ [
        # Mouse movement and resize.
        (hyprLua.bindWith "${mod}, mouse:272" "hl.dsp.window.drag()" { mouse = true; })
        (hyprLua.bindWith "${mod}, mouse:273" "hl.dsp.window.resize()" { mouse = true; })
      ];
  };
}
