let
  nginx = import ./nginx;
in {
  inherit nginx;

  pipewire = import ./pipewire;
  useDocker = import ./docker;
  useDeluge = import ./deluge;
  useEasyEffects = import ./easyeffects;
  useFlatpak = import ./flatpak;
  useGpuScreenRecorder = import ./gpu-screen-recorder;
  useHomeManager = import ./home-manager;
  useJetbrainsRemote = import ./jetbrains-remote;
  useKeyd = import ./keyd;
  useLibinput = import ./libinput;
  useLinuxWallpaperengine = import ./linux-wallpaperengine;
  useNginX = nginx.useNginX;
  useRemovableStorageAutoMount = import ./removable-storage-auto-mount;
  useRtkit = import ./rtkit;
  useSamba = import ./samba;
  useSpotifySoloist = import ./spotify-soloist;
  useSsh = import ./ssh;
  useSyncthing = import ./syncthing;
  useTailscale = import ./tailscale;
  useVscodeServer = import ./vscode-server;
}
