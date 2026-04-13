# RFLXN's NixOS Flake

This repository manages three NixOS machines from one flake using small curried modules and host-level composition.

- `rflxn-desktop`: `x86_64-linux` AMD desktop, Hyprland workstation and gaming box
- `rflxn-asahi`: `aarch64-linux` Apple Silicon laptop, Asahi Linux plus Hyprland
- `rflxn-server`: `x86_64-linux` headless server for remote development and network services

![3 NixOS Systems](./vdg.jpg)

## Repository Layout

```text
nix/
├── flake.nix
├── modules/
│   ├── desktop/
│   ├── hardware/
│   ├── programs/
│   ├── services/
│   └── system/
└── hosts/
    ├── rflxn-asahi/
    ├── rflxn-desktop/
    └── rflxn-server/
```

## Composition Model

Most reusable modules follow this pattern:

```nix
{ optionA ? defaultA, ... }:
{ pkgs, lib, username, ... }:
{ ... }
```

`flake.nix` passes shared `specialArgs` into each host:

- `modules`: the module library exported from `./modules`
- `shared`: common values such as `username`, timezone, locale, and Syncthing device IDs
- `username`: convenience alias from `shared.username`
- `defaultPersistPath = "/persist"`
- selected flake inputs needed by the host, such as `home-manager`, `impermanence`, `hyprland`, `hyprshell`, `quickshell`, `apple-silicon`, and `vscode-server`

Host composition style:

- `hosts/rflxn-desktop/` splits its config into `desktop.nix`, `services.nix`, `programs.nix`, and `systems.nix`
- `hosts/rflxn-asahi/configuration.nix` composes most modules inline because the machine is more specialized
- `hosts/rflxn-server/configuration.nix` keeps most of the headless service stack in one place

## Flake Overview

`flake.nix` currently tracks:

- `nixpkgs = github:NixOS/nixpkgs/nixos-unstable`
- `home-manager`
- `impermanence`
- `plasma-manager`
- `vscode-server`
- `lanzaboote`
- `apple-silicon`
- `aarch64-widevine`
- `hyprland`
- `hyprshell`
- `quickshell`
- `astal`
- `ags`
- `claude-code`
- `codex-cli-nix`
- `t3code`
- `battery-logger`

Shared values defined directly in the flake:

- `username = "rflxn"`
- `timezone = "Asia/Seoul"`
- `locale = "en_US.UTF-8"`
- Syncthing device IDs for all three hosts

Per-host entrypoints:

- `hosts/rflxn-desktop/default.nix`
- `hosts/rflxn-asahi/default.nix`
- `hosts/rflxn-server/default.nix`

## Host Profiles

### `rflxn-desktop`

- Platform: `x86_64-linux`
- Role: main desktop and gaming workstation
- Session stack: Hyprland with UWSM, greetd autologin, AGS, Hyprshell, Hyprlock, Hyprpolkit, and tray bridge
- Display layout: `DP-3` and rotated `HDMI-A-1`, with workspaces `1` to `5` on `DP-3` using `master` and workspace `6` on `HDMI-A-1` using `scrolling`
- Theme: Rose Pine GTK and Qt, Papirus icons, Rose Pine cursor and hyprcursor
- Wallpaper and rules: Linux Wallpaper Engine per monitor, Spotify and Vesktop pinned to workspace `6`
- Services: PipeWire with low-latency and denoised mic config, rootless Docker on `btrfs`, Flatpak, GPU Screen Recorder, keyd, Home Manager, Syncthing user service, Tailscale, and rtkit
- Programs: browsers, IDEs, AI tooling, gaming tools, media tools, and general desktop apps
- System: EFI, systemd-boot, Lanzaboote, Plymouth, impermanence, NetworkManager Wi-Fi, zram, AMD GPU tuning, Bluetooth, and shared font and IME setup

### `rflxn-asahi`

- Platform: `aarch64-linux`
- Role: Apple Silicon laptop
- Session stack: Hyprland with UWSM, greetd autologin, AGS, Hyprshell, Hyprlock, and Hyprpolkit
- Input and display: built-in `eDP-1`, touchpad defaults, 3-finger workspace gesture, and Mac-style key remaps through keyd
- Monitor toggle: `SUPER SHIFT, P` switches `eDP-1` between `60 Hz` and `120 Hz`
- Firmware: requires a local `hosts/rflxn-asahi/firmware` directory
- Services: PipeWire, battery logger for `macsmc-battery`, rootless Docker on `btrfs`, Flatpak, keyd, libinput, rtkit, Home Manager, Syncthing user service, and Tailscale with systray support
- Programs: desktop and development tools, including Firefox with aarch64 Widevine support
- System: Apple Silicon support module, EFI with `canTouchEfiVariables = false`, systemd-boot, impermanence, NetworkManager Wi-Fi, Bluetooth, graphics with `enable32Bit = false`, zram, shared font and IME setup

### `rflxn-server`

- Platform: `x86_64-linux`
- Role: headless server, remote development host, and sync box
- Services: Docker, Cloudflare DDNS OCI container, Home Manager, JetBrains Remote, SSH, Samba, Tailscale, VS Code server, Syncthing system service, Deluge, and nginx
- Reverse proxy: nginx exposes Deluge under `/torrent` and Syncthing under `/syncthing`
- Programs: zsh, git, direnv, nix-index, Claude Code, and common CLI tooling
- System: EFI, systemd-boot, impermanence, and standard nix cache, GC, and optimise settings

## Build and Inspection

```bash
# Inspect the flake
nix flake show

# Build without switching
nix build .#nixosConfigurations.rflxn-desktop.config.system.build.toplevel
nix build .#nixosConfigurations.rflxn-asahi.config.system.build.toplevel
nix build .#nixosConfigurations.rflxn-server.config.system.build.toplevel

# Switch
sudo nixos-rebuild switch --flake .#rflxn-desktop
sudo nixos-rebuild switch --flake .#rflxn-asahi
sudo nixos-rebuild switch --flake .#rflxn-server
```

## Prerequisites and Secrets

### Global

1. The hosts assume a `btrfs` layout with `@root`, `@root-blank`, `@nix`, and `@persist`.
2. `/persist` is the default persistence root passed into modules.
3. Create the user password hash file:

```bash
mkdir -p /persist/secrets
mkpasswd -m sha-512 > /persist/secrets/rflxn.hashedPassword
```

### Desktop (`rflxn-desktop`)

- If you use Lanzaboote and Secure Boot, create and enroll `sbctl` keys.
- The boot module persists `/var/lib/sbctl`.

### Asahi (`rflxn-asahi`)

- Extract firmware into `hosts/rflxn-asahi/firmware`.
- Builds will throw if that directory is missing.

### Server (`rflxn-server`)

- Cloudflare DDNS expects:

```bash
mkdir -p /persist/secrets
printf 'API_KEY=your_cloudflare_api_token\n' > /persist/secrets/ddns.env
```

- Deluge expects:
  - `/persist/secrets/deluge.auth` in Deluge `auth` file format
  - `/persist/secrets/deluge-web.auth` as JSON with `pwd_salt` and `pwd_sha1`

## Module API Map

The list below reflects the currently exported helper surface from `modules/`.

### `modules.desktop`

- `useGreetd { enableRegreet ? false, regreetCompositor ? "hyprland", regreetPrimaryMonitor ? null, enableAutoLogin ? false, autoLoginSession ? "uwsm-hyprland" }`
- `useSddm { enableHidpi ? false, waylandCompositor ? "weston" }`
- `useXdgPortal { enableKdeSupport ? false, enableHyprlandSupport ? false, enableGtkSupport ? enableHyprlandSupport }`

#### `modules.desktop.defaultApps`

- `useDefaultApps {}`
- `useFirefox { mimeTypes ? [...] }`
- `useHaruna {}`
- `useKitty {}`
- `useLibreOffice {}`
- `usePeaZip {}`
- `useVscode { mimeTypes ? [...] }`

#### `modules.desktop.gtk.theme`

- `usePapirusIcon { theme ? "Papirus-Dark" }`
- `useRosePine { variant ? "main", windowOpacity ? 0.85 }`

#### `modules.desktop.hyprland`

- `appearance { gapSize ? 5, borderSize ? 2, rounding ? 5, activeBorderColor ? "rgb(89b4fa)", inactiveBorderColor ? "rgb(585b70)", enableAnimations ? true, enableBlur ? true, activeOpacity ? 0.94, inactiveOpacity ? 0.86, fullscreenOpacity ? 1.0, blurSize ? 8, blurPasses ? 2 }`
- `useAgs { sourceDir ? null }`
- `useDarkMode { qtUseGtkPlatformTheme ? true }`
- `useDunst { fontSize ? 11, font ? "Noto Sans", cornerRadius ? 10, width ? 350, offset ? "15x15" }`
- `useHyprbars {}`
- `useHypridle { timeToScreenOff ? 600, timeToLock ? 900, timeToSuspend ? 1800 }`
- `useHyprland { enableXWayland ? true, monitors ? null, workspaces ? null, followMouse ? 1, pointerSpeed ? 0, enableMouseAcceleration ? false, disableHardwareCursors ? false }`
- `useHyprlock {}`
- `useHyprpolkit {}`
- `useQuickShell {}`
- `useHyprshell { modifier ? "alt" }`
- `useRofi {}`
- `useTrayBridge {}`
- `useWaybar {}`

#### `modules.desktop.hyprland.cursors`

- `useRosePineCursor { cursorSize ? 24 }`

#### `modules.desktop.hyprland.keybinds`

- `useDefaults { mod ? "SUPER", subMod ? "SUPER SHIFT" }`
- `useAgsLauncher { key ? "SUPER, D" }`
- `useAgsRestart { key ? "SUPER, backslash" }`
- `useGsrSaveReplay { key ? "ALT, F9" }`
- `useHyprshot { key ? "Print" }`
- `useKitty { key ? "SUPER, R" }`
- `useRofi { key ? "SUPER, D" }`
- `useScreenOff { key ? "SUPER SHIFT, O", delaySeconds ? 1 }`
- `useSpectacle { key ? ", Print" }`
- `useToggleMonitorSetup { settings ? [] }`

#### `modules.desktop.hyprland.touchpad`

- `useDefaults {}`

#### `modules.desktop.hyprland.touchpad.gestures`

- `useWorkspaces {}`

#### `modules.desktop.hyprland.wallpaper`

- `useHyprpaper { wallpaper ? null, monitors ? [], wallpapers ? [] }`
- `useLinuxWallpaperEngine { wallpapers, fps ? 60 }`

#### `modules.desktop.hyprland.windowRules`

- `useDefaults {}`
- `useFixedSpotify { workspace }`
- `useFixedVesktop { workspace }`
- `useWorkspacePseudo { workspace }`

#### `modules.desktop.logind`

- `useLogind {}`

#### `modules.desktop.plasma6`

- `usePlasma6 { overrideConfig ? false, excludePackages ? [], enableSddmIntegration ? true, persistPath ? null }`

#### `modules.desktop.plasma6.kwin`

- `disableWindowBarrier {}`
- `useBlur { strength ? 5 }`

#### `modules.desktop.plasma6.shortcuts`

- `useGsrSaveReplay { key }`
- `useKitty { key }`
- `useRestartWallpaper { key }`

#### `modules.desktop.plasma6.theme`

- `useLeaf {}`

#### `modules.desktop.qt.theme`

- `usePapirusIcon { theme ? "Papirus-Dark" }`
- `useRosePine { variant ? "main", accent ? "rose", useOverlay ? true, kvantumTranslucentWindows ? true, kvantumBlurring ? true, kvantumPopupBlurring ? true, kvantumReduceWindowOpacity ? 12 }`

### `modules.services`

- `pipewire.usePipewire {}`
- `pipewire.useDenoisedMic {}`
- `pipewire.useLowLatency {}`
- `useBatteryLogger { logFile ? null, lockFile ? null, powerSupplyDir ? null, batteryDeviceName ? null }`
- `useDeluge { authFile ? null, downloadDir ? null, webAuthFile ? null, webHost ? "0.0.0.0", webPort ? 8112, persistPath ? null }`
- `useDocker { isBtrfs ? false, isRootless ? false, containersAsService ? {}, persistPath ? null }`
- `useFlatpak { persistPath ? null }`
- `useGpuScreenRecorder { window ? "screen", framerate ? 60, replaySeconds ? 300, quality ? "high", container ? "mp4", audioSource ? "default_output", outputDir ? null }`
- `useHomeManager { stateVersion ? "25.11", backupCommand ? null }`
- `useJetbrainsRemote { ides ? [] }`
- `useKeyd { settings ? {} }`
- `useLibinput {}`
- `useLinuxWallpaperengine { wallpapers, fps ? 60, bindToPlasma ? false }`
- `useNginX { upstreams ? {} }`
- `useRtkit {}`
- `useSamba { directories ? {}, persistPath ? null }`
- `useSsh { persistPath ? null, allowPasswordLogin ? false }`
- `useSyncthing { devices ? {}, folders ? {}, serviceLevel ? "user", webHost ? "0.0.0.0", webPort ? 8384, persistPath ? null }`
- `useTailscale { persistPath ? null, enableSystemTray ? false }`
- `useVscodeServer {}`

#### `modules.services.nginx.vhosts`

- `useDeluge { port ? 8112 }`
- `useSyncthing { port ? 8384 }`

### `modules.programs`

#### Aggregated namespaces

- `shell.useShell {}`
- `shell.useZsh {}`
- `jetbrains.useIntellij { enableZshAlias ? false }`
- `jetbrains.usePycharm { enableZshAlias ? false }`
- `jetbrains.useWebstorm { enableZshAlias ? false }`
- `gaming.useLsfgVk {}`
- `gaming.useLutris {}`
- `gaming.useProtonplus {}`
- `gaming.useR2modman {}`
- `gaming.useSteam { enableGamescope ? false, enableProtontricks ? false }`
- `gaming.useWine { isWayland ? false }`

#### Direct helpers

- `useAyugram {}`
- `useBlueman {}`
- `useClaudeCode {}`
- `useCodex {}`
- `useCommonTools {}`
- `useChrome {}`
- `useDirenv {}`
- `useDiscord {}`
- `useDolphin {}`
- `useFastfetch { beforeModules ? [], afterModules ? [] }`
- `useFirefox { enableWidevine ? false }`
- `useForgeCode { enableZshIntegration ? false }`
- `useGit { name, email }`
- `useHaruna {}`
- `useHyprshot {}`
- `useKcalc { enableWindowsAlias ? false }`
- `useKdenLive {}`
- `useKitty {}`
- `useKolourpaint { enableWindowsAlias ? false }`
- `useLact { enableDaemon ? true }`
- `useLibreOffice {}`
- `useMoonlight {}`
- `useNixIndex {}`
- `useNmApplet {}`
- `useObsStudio { enableVirtualCamera ? false, enableAmdVaapi ? true, extraPlugins ? [] }`
- `usePeaZip {}`
- `usePwvucontrol {}`
- `useShotcut {}`
- `useSpectacle {}`
- `useSpotify {}`
- `useT3 {}`
- `useThunar {}`
- `useVscode {}`
- `useWaylandUtils {}`

### `modules.hardware`

- `useAmdGpu { enable32Bit ? true, enableOverdrive ? false }`
- `useBluetooth { persistPath ? null }`
- `useGraphics { enable32Bit ? true }`
- `useOpenrazer {}`

### `modules.system`

#### `modules.system.boot`

- `useEfiBoot { canTouchEfiVariables ? false }`
- `useLanzaboote { persistPath ? null }`
- `usePlymouth { theme ? "breeze", enableQuietBoot ? true }`
- `useSystemdBoot { consoleMode ? null, configurationLimit ? 15 }`

#### `modules.system.nix`

- `useCache {}`
- `useExperimentalFeatures {}`
- `useGc { dates }`
- `useOptimise { dates }`
- `useUnfreePackage {}`

#### `modules.system` helpers

- `useCjkFonts {}`
- `useFcitx5 {}`
- `useImpermanence { rootUuid, persistPath ? null, directories ? [], files ? [] }`
- `useMe { hashedPassword ? null, hashedPasswordFile ? null, extraGroups ? [] }`
- `useNetworkManager { useWifi ? false, persistPath ? null }`
- `useZram { memoryPercent ? 25, priority ? 10 }`

## AGS Workflow

Current behavior of `modules/desktop/hyprland/ags/default.nix`:

- The module installs AGS and the Astal packages it needs.
- Hyprland autostarts `ags run`.
- `~/.config/ags` is intentionally left unmanaged for live local iteration.
- The `sourceDir` argument exists, but the out-of-store symlink line is currently commented out in the module.
