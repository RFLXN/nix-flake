# RFLXN's NixOS Flake

This repository manages three NixOS machines with a module-host composition pattern:

- `rflxn-desktop` (x86_64, Hyprland stack)
- `rflxn-asahi` (aarch64, Apple Silicon + Plasma 6)
- `rflxn-server` (x86_64, headless/server workloads)

![3 NixOS Systems](./vdg.jpg)

## Repository Layout

```text
nix/
├── flake.nix
├── modules/
│   ├── desktop/
│   ├── services/
│   ├── programs/
│   ├── hardware/
│   └── system/
└── hosts/
    ├── rflxn-desktop/
    ├── rflxn-asahi/
    └── rflxn-server/
```

## Composition Model

Modules follow a curried pattern:

```nix
{ optionA ? defaultA, ... }:
{ pkgs, lib, username, ... }:
{ ...config... }
```

Hosts compose those modules in `hosts/<name>/configuration.nix`.

## Flake Overview

`flake.nix` defines:

- Stable base: `nixos-25.11`
- Additional inputs: `home-manager`, `impermanence`, `plasma-manager`, `lanzaboote`, `vscode-server`, `apple-silicon`, `astal`, `ags`, etc.
- Shared values: `username`, locale/timezone, Syncthing device IDs
- Per-host `mkSystem` entrypoints:
  - `hosts/rflxn-desktop/default.nix`
  - `hosts/rflxn-asahi/default.nix`
  - `hosts/rflxn-server/default.nix`

## Host Profiles

### `rflxn-desktop`

- Platform: `x86_64-linux`
- DE stack: Hyprland + UWSM + greetd + AGS + Hyprshell/Hyprpaper/Hyprpolkit/Hyprbars
- Theming: Rose Pine GTK + Rose Pine Kvantum Qt + Rose Pine cursor (xcursor + hyprcursor)
- Services: PipeWire (low-latency + denoised mic), rootless Docker (btrfs), Syncthing user service, Tailscale, keyd, GPU screen recorder
- Programs: extensive desktop/gaming/dev set (Kitty, VSCode, Firefox, Steam, Wine, JetBrains, etc.)
- Boot/system: Lanzaboote + systemd-boot + Impermanence + NetworkManager (Wi-Fi) + zram

### `rflxn-asahi`

- Platform: `aarch64-linux` (Apple Silicon)
- DE stack: Plasma 6 + SDDM (HiDPI)
- Firmware: requires local Asahi firmware directory at `hosts/rflxn-asahi/firmware`
- Services: PipeWire, rootless Docker (btrfs), Syncthing user service, Tailscale, keyd/libinput/rtkit
- Programs: desktop/dev suite with aarch64 Firefox Widevine support
- Boot/system: EFI (`canTouchEfiVariables = false`), systemd-boot, Impermanence, NetworkManager (Wi-Fi), zram

### `rflxn-server`

- Platform: `x86_64-linux`
- Role: headless server + remote/dev infra
- Services: Docker (includes Cloudflare DDNS container), Syncthing system service, SSH, Tailscale, VSCode server, JetBrains Remote
- Programs: shell + dev CLI essentials
- Boot/system: EFI + systemd-boot + Impermanence

## Build Commands

```bash
# Desktop
sudo nixos-rebuild switch --flake .#rflxn-desktop

# Asahi
sudo nixos-rebuild switch --flake .#rflxn-asahi

# Server
sudo nixos-rebuild switch --flake .#rflxn-server
```

## Prerequisites & Secrets

### Global

1. Btrfs layout is expected (`@root`, `@nix`, `@persist` subvolumes).
2. User password hash file:

```bash
mkdir -p /persist/secrets
mkpasswd -m sha-512 > /persist/secrets/rflxn.hashedPassword
```

### Desktop (`rflxn-desktop`)

- If using Lanzaboote/Secure Boot, create and enroll keys for `sbctl` (stored at `/var/lib/sbctl`, persisted by module config).

### Asahi (`rflxn-asahi`)

- Provide firmware files in `hosts/rflxn-asahi/firmware` (gitignored).
- Build throws if firmware is missing.

### Server (`rflxn-server`)

- DDNS container expects:

```bash
mkdir -p /persist/secrets
echo "API_KEY=your_cloudflare_api_token" > /persist/secrets/ddns.env
```

## Module API Map

This section is a practical map of exported helpers.

### `modules.desktop`

- `useSddm { enableHidpi ? false, waylandCompositor ? "weston" }`
- `useGreetd { compositor ? "hyprland", primaryMonitor }`
- `useXdgPortal { enableKdeSupport ? false, enableHyprlandSupport ? false, enableGtkSupport ? enableHyprlandSupport }`

#### `modules.desktop.hyprland`

- `useHyprland { enableXWayland ? true, monitors ? null, workspaces ? null, followMouse ? 1, pointerSpeed ? 0, enableMouseAcceleration ? false }`
- `keybinds.useDefaults { mod ? "SUPER", subMod ? "SUPER SHIFT" }`
- `keybinds.useKitty { key ? "SUPER, R" }`
- `keybinds.useRofi { key ? "SUPER, D" }`
- `keybinds.usePrintscreen { key ? ", Print" }`
- `keybinds.useGsrSaveReplay { key ? "ALT, F9" }`
- `keybinds.useAgsLauncher { key ? "SUPER, D" }`
- `keybinds.useAgsRestart { key ? "SUPER, backslash" }`
- `appearance { gapSize ? 5, borderSize ? 2, rounding ? 10, activeBorderColor ? "rgb(89b4fa)", inactiveBorderColor ? "rgb(585b70)", enableAnimations ? true, enableBlur ? true, activeOpacity ? 0.94, inactiveOpacity ? 0.86, fullscreenOpacity ? 1.0, blurSize ? 8, blurPasses ? 2 }`
- `useDarkMode { qtUseGtkPlatformTheme ? true }`
- `useDunst { fontSize ? 11, font ? "Noto Sans", cornerRadius ? 10, width ? 350, offset ? "15x15" }`
- `useRofi {}`
- `useHyprshell { modifier ? "alt" }`
- `useHyprpolkit {}`
- `useHyprpaper { wallpaper ? null, monitors ? [], wallpapers ? [] }`
- `useWaybar {}`
- `useHyprbars {}`
- `useTrayBridge {}`
- `useAgs { configDir ? null, sourceDir ? ./.config }`
- `cursors.useRosePineCursor { cursorSize ? 24 }`
- `windowRules.useDefaults {}`
- `windowRules.useFixedVesktop { workspace }`
- `windowRules.useFixedSpotify { workspace }`

#### `modules.desktop.plasma6`

- `usePlasma6 { overrideConfig ? false, excludePackages ? [], enableSddmIntegration ? true, persistPath ? null }`
- `kwin.useBlur { strength ? 5 }`
- `kwin.disableWindowBarrier {}`
- `shortcuts.useKitty { key }`
- `shortcuts.useGsrSaveReplay { key }`
- `shortcuts.useRestartWallpaper { key }`
- `theme.useLeaf {}`

#### `modules.desktop.gtk`

- `theme.useRosePine { variant ? "main", windowOpacity ? 0.85 }`

#### `modules.desktop.qt`

- `theme.useRosePine { variant ? "main", accent ? "rose", iconTheme ? null, useOverlay ? true, kvantumTranslucentWindows ? true, kvantumBlurring ? true, kvantumPopupBlurring ? true, kvantumReduceWindowOpacity ? 12 }`

### `modules.services`

- `useDocker { isBtrfs ? false, isRootless ? false, containersAsService ? {}, persistPath ? null }`
- `useGpuScreenRecorder { window ? "screen", framerate ? 60, replaySeconds ? 300, quality ? "high", container ? "mp4", audioSource ? "default_output", outputDir ? null }`
- `useHomeManager { stateVersion ? "25.11", backupCommand ? null }`
- `useJetbrainsRemote { ides ? [] }`
- `useKeyd { settings ? {} }`
- `useLibinput {}`
- `pipewire.usePipewire {}`
- `pipewire.useLowLatency {}`
- `pipewire.useDenoisedMic {}`
- `useRtkit {}`
- `useSsh { persistPath ? null, allowPasswordLogin ? false }`
- `useSyncthing { devices ? {}, folders ? {}, serviceLevel ? "user", persistPath ? null }`
- `useTailscale { persistPath ? null }`
- `useVscodeServer {}`
- `useLinuxWallpaperengine { wallpapers, fps ? 60 }`

### `modules.programs`

#### Aggregated objects

- `shell.useShell {}`
- `shell.useZsh {}`
- `jetbrains.useWebstorm { enableZshAlias ? false }`
- `jetbrains.useIntellij { enableZshAlias ? false }`
- `jetbrains.usePycharm { enableZshAlias ? false }`
- `gaming.useSteam { enableGamescope ? false, enableProtontricks ? false }`
- `gaming.useR2modman {}`
- `gaming.useProtonplus {}`
- `gaming.useLsfgVk {}`
- `gaming.useWine { isWayland ? false }`

#### Single helpers

- `useFirefox { enableWidevine ? false }`
- `useVscode {}`
- `useClaudeCode {}`
- `useKitty {}`
- `useGit { name, email }`
- `useFastfetch { beforeModules ? [], afterModules ? [] }`
- `useDiscord {}`
- `useSpotify {}`
- `useNixIndex {}`
- `useDirenv {}`
- `useCommonTools {}`
- `useHaruna {}`
- `useKcalc { enableWindowsAlias ? false }`
- `useKolourpaint { enableWindowsAlias ? false }`
- `useLact { enableDaemon ? true }`
- `useThunar {}`
- `useWaylandUtils {}`
- `useAyugram {}`
- `useBlueman {}`
- `useNmApplet {}`
- `useCodex {}`
- `useDolphin {}`

### `modules.hardware`

- `useGraphics {}`
- `useBluetooth { persistPath ? null }`
- `useAmdGpu { enable32Bit ? true, enableOverdrive ? false }`
- `useOpenrazer {}`

### `modules.system`

- `boot.useEfiBoot { canTouchEfiVariables ? false }`
- `boot.useSystemdBoot { consoleMode ? null, configurationLimit ? 15 }`
- `boot.useLanzaboote { persistPath ? null }`
- `boot.usePlymouth { theme ? "breeze", enableQuietBoot ? true }`
- `nix.useExperimentalFeatures {}`
- `nix.useUnfreePackage {}`
- `nix.useGc { dates }`
- `nix.useOptimise { dates }`
- `nix.useCache {}`
- `useNetworkManager { useWifi ? false, persistPath ? null }`
- `useZram { memoryPercent ? 25, priority ? 10 }`
- `useImpermanence { rootUuid, persistPath ? null, directories ? [], files ? [] }`
- `useMe { hashedPassword ? null, hashedPasswordFile ? null, extraGroups ? [] }`
- `useFcitx5 {}`
- `useCjkFonts {}`

## AGS Workflow (Current)

Recommended development loop:

- Keep AGS source in `my-ags/`
- Symlink for fast iteration:

```bash
ln -sfn /home/rflxn/nix/my-ags ~/.config/ags
```

Declarative snapshot also exists at `modules/desktop/hyprland/ags/.config/`, but active development is expected to happen in `my-ags/` and then be synced intentionally.
