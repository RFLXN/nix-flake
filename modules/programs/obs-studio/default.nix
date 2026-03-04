{
  enableVirtualCamera ? false,
  enableAmdVaapi ? true,
  extraPlugins ? [],
}:
{ pkgs, lib, ... }: {
  programs.obs-studio = {
    enable = true;
    inherit enableVirtualCamera;
    plugins =
      (with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
        obs-gstreamer
        obs-vkcapture
      ])
      ++ lib.optionals enableAmdVaapi [ pkgs.obs-studio-plugins.obs-vaapi ]
      ++ extraPlugins;
  };
}
