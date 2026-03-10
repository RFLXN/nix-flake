{
  pipewire = import ./pipewire;
  useBatteryLogger = import ./battery-logger;
  useDocker = import ./docker;
  useFlatpak = import ./flatpak;
  useGpuScreenRecorder = import ./gpu-screen-recorder;
  useHomeManager = import ./home-manager;
  useJetbrainsRemote = import ./jetbrains-remote;
  useKeyd = import ./keyd;
  useLibinput = import ./libinput;
  useLinuxWallpaperengine = import ./linux-wallpaperengine;
  useRtkit = import ./rtkit;
  useSsh = import ./ssh;
  useSyncthing = import ./syncthing;
  useTailscale = import ./tailscale;
  useVscodeServer = import ./vscode-server;
}
