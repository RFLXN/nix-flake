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
{ lib, pkgs, username, ... }:
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
    bindel = [
      ", XF86AudioRaiseVolume, exec, ${wireplumber}/bin/wpctl set-volume -l ${maxVolume} ${sink} ${volumeStep}+"
      ", XF86AudioLowerVolume, exec, ${wireplumber}/bin/wpctl set-volume ${sink} ${volumeStep}-"
    ];

    bindl =
      [
        ", XF86AudioMute, exec, ${wireplumber}/bin/wpctl set-mute ${sink} toggle"
        ", XF86AudioPlay, exec, ${playerctl}/bin/playerctl play-pause"
        ", XF86AudioPause, exec, ${playerctl}/bin/playerctl play-pause"
        ", XF86AudioNext, exec, ${playerctl}/bin/playerctl next"
        ", XF86AudioPrev, exec, ${playerctl}/bin/playerctl previous"
      ]
      ++ lib.optionals enableMicMute [
        ", XF86AudioMicMute, exec, ${wireplumber}/bin/wpctl set-mute ${source} toggle"
      ]
      ++ lib.optionals enableStop [
        ", XF86AudioStop, exec, ${playerctl}/bin/playerctl stop"
      ];
  };
}
