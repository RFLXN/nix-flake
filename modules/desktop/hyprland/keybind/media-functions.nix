{
  enableMicMute ? true,
  enableStop ? true,
  maxVolume ? "1.0",
  playerctlPackage ? null,
  sink ? "@DEFAULT_AUDIO_SINK@",
  source ? "@DEFAULT_AUDIO_SOURCE@",
  volumeStep ? "5%",
  wireplumberPackage ? null,
}:
{ hyprLua, lib, pkgs, username, ... }:
let
  playerctl =
    if playerctlPackage == null then
      pkgs.playerctl
    else
      playerctlPackage;
  wireplumber =
    if wireplumberPackage == null then
      pkgs.wireplumber
    else
      wireplumberPackage;
in
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings = {
    # Repeat volume changes while the key is held, and keep them available while locked.
    bind =
      [
        (hyprLua.execBindWith ", XF86AudioRaiseVolume" "${wireplumber}/bin/wpctl set-volume -l ${maxVolume} ${sink} ${volumeStep}+" {
          locked = true;
          repeating = true;
        })
        (hyprLua.execBindWith ", XF86AudioLowerVolume" "${wireplumber}/bin/wpctl set-volume ${sink} ${volumeStep}-" {
          locked = true;
          repeating = true;
        })
        (hyprLua.execBindWith ", XF86AudioMute" "${wireplumber}/bin/wpctl set-mute ${sink} toggle" { locked = true; })
        (hyprLua.execBindWith ", XF86AudioPlay" "${playerctl}/bin/playerctl play-pause" { locked = true; })
        (hyprLua.execBindWith ", XF86AudioPause" "${playerctl}/bin/playerctl play-pause" { locked = true; })
        (hyprLua.execBindWith ", XF86AudioNext" "${playerctl}/bin/playerctl next" { locked = true; })
        (hyprLua.execBindWith ", XF86AudioPrev" "${playerctl}/bin/playerctl previous" { locked = true; })
      ]
      ++ lib.optionals enableMicMute [
        (hyprLua.execBindWith ", XF86AudioMicMute" "${wireplumber}/bin/wpctl set-mute ${source} toggle" { locked = true; })
      ]
      ++ lib.optionals enableStop [
        (hyprLua.execBindWith ", XF86AudioStop" "${playerctl}/bin/playerctl stop" { locked = true; })
      ];
  };
}
