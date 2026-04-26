# API.md

Reference for the current exported API under `./modules`.

This file documents the repo-local module surface, not upstream NixOS or Home Manager options.

## Usage Model

Most reusable modules in this repo are curried:

```nix
{ optionA ? defaultA, ... }:
{ pkgs, lib, username, ... }:
{ ... }
```

Typical usage:

```nix
{ modules, ... }: {
  imports = with modules.system; [
    (boot.useSystemdBoot {})
    (useMe { hashedPasswordFile = "/persist/secrets/rflxn.hashedPassword"; })
  ];
}
```

## Cross-Cutting Requirements

- Most desktop and program modules write to `home-manager.users.${username}`. They assume `modules.services.useHomeManager {}` is imported in the host.
- Persistence-aware modules assume `defaultPersistPath = "/persist"` is available through `specialArgs`, unless `persistPath` is passed explicitly.
- Many modules assume `username` is provided through `specialArgs`.
- Some modules require flake inputs to be passed into host `specialArgs`.

Required input-backed modules:

| Module | Required special arg |
| --- | --- |
| `modules.system.boot.useLanzaboote` | `lanzaboote` |
| `modules.system.useImpermanence` | `impermanence` |
| `modules.desktop.plasma6.usePlasma6` | `plasma-manager` |
| `modules.desktop.hyprland.useAgs` | `rflxn-shell` |
| `modules.desktop.hyprland.useHyprland` | optional `hyprland` input, otherwise falls back to `pkgs.hyprland` |
| `modules.desktop.hyprland.useHyprshell` | optional `hyprshell` input, otherwise falls back to `pkgs.hyprshell` |
| `modules.programs.useClaudeCode` | `claude-code` |
| `modules.programs.useCodex` | `codex-cli-nix` |
| `modules.programs.useCodexDesktop` | `codex-desktop` |
| `modules.programs.useT3` | `t3code` |
| `modules.programs.useFirefox { enableWidevine = true; }` | optional `aarch64-widevine` on Asahi |
| `modules.services.useBatteryLogger` | `battery-logger` |
| `modules.services.useHomeManager` | `home-manager` |
| `modules.services.useVscodeServer` | `vscode-server` |

## Export Tree

```nix
modules = {
  desktop = {
    defaultApps = { ... };
    gtk.theme = { ... };
    hyprland = {
      cursors = { ... };
      keybinds = { ... };
      touchpad = {
        gestures = { ... };
        ...
      };
      wallpaper = { ... };
      windowRules = { ... };
      ...
    };
    logind = { ... };
    plasma6 = {
      kwin = { ... };
      shortcuts = { ... };
      theme = { ... };
      ...
    };
    qt.theme = { ... };
    useGreetd = ...;
    useSddm = ...;
    useXdgPortal = ...;
  };

  hardware = {
    useAmdGpu = ...;
    useBluetooth = ...;
    useGraphics = ...;
    useOpenrazer = ...;
  };

  programs = {
    gaming = { ... };
    jetbrains = { ... };
    shell = { ... };
    ...
  };

  services = {
    nginx = {
      useNginX = ...;
      vhosts = { ... };
    };
    pipewire = { ... };
    ...
  };

  system = {
    boot = { ... };
    nix = { ... };
    ...
  };
}
```

## `modules.system`

### `modules.system.boot`

- `boot.useEfiBoot { canTouchEfiVariables ? false }`
  Sets `boot.loader.efi.canTouchEfiVariables`.

- `boot.useLanzaboote { persistPath ? null }`
  Enables Lanzaboote, disables direct `systemd-boot`, installs `sbctl`, and persists `/var/lib/sbctl` when a persistence path is available.

- `boot.usePlymouth { theme ? "breeze", enableQuietBoot ? true }`
  Enables Plymouth and optionally sets quiet boot kernel/initrd flags.

- `boot.useSystemdBoot { consoleMode ? null, configurationLimit ? 15 }`
  Enables `boot.loader.systemd-boot` and optionally sets console mode and configuration retention.

### `modules.system.nix`

- `nix.useCache {}`
  Enables the configured binary caches and trusted public keys for this repo.

- `nix.useExperimentalFeatures {}`
  Enables `nix-command` and `flakes`.

- `nix.useGc { dates }`
  Enables automatic GC with the provided `dates` value.

- `nix.useOptimise { dates }`
  Enables automatic Nix store optimisation with the provided `dates` value.

- `nix.useUnfreePackage {}`
  Sets `nixpkgs.config.allowUnfree = true`.

### Other `modules.system` exports

- `useCjkFonts {}`
  Installs and configures the repo's default Latin, Korean, and Japanese fonts, including custom `fontconfig` language preferences.

- `useFcitx5 {}`
  Enables `fcitx5` with GTK, Hangul, and Mozc addons.

- `useImpermanence { rootUuid, persistPath ? null, directories ? [], files ? [] }`
  Enables impermanence, resets `@root` from `@root-blank` during initrd, persists `/home`, logs, `machine-id`, and any extra directories/files provided.

- `useMe { hashedPassword ? null, hashedPasswordFile ? null, extraGroups ? [] }`
  Creates the main user from `username`, disables mutable users, adds `wheel`, and accepts either an inline hash or a password-hash file.

- `useNetworkManager { useWifi ? false, persistPath ? null }`
  Enables NetworkManager, adds the user to `networkmanager`, optionally enables `iwd`-backed Wi-Fi, and persists NetworkManager state when a persistence path is available.

- `useZram { memoryPercent ? 25, priority ? 10 }`
  Enables zram swap with configurable memory percentage and priority.

## `modules.hardware`

- `useAmdGpu { enable32Bit ? true, enableOverdrive ? false }`
  Enables `amdgpu`, sets X11 video driver to `amdgpu`, enables hardware graphics, and optionally enables AMD overdrive.

- `useBluetooth { persistPath ? null }`
  Enables Bluetooth with `Experimental`, `FastConnectable`, and auto-enable behavior, installs `upower`, and persists `/var/lib/bluetooth` when a persistence path is available.

- `useGraphics { enable32Bit ? true }`
  Enables `hardware.graphics` with optional 32-bit support.

- `useOpenrazer {}`
  Enables OpenRazer and grants access to the repo user.

## `modules.desktop`

### Top-level exports

- `useGreetd { enableRegreet ? false, regreetCompositor ? "hyprland", regreetPrimaryMonitor ? null, enableAutoLogin ? false, autoLoginSession ? "uwsm-hyprland" }`
  Enables `greetd` for either Regreet or autologin.
  `regreetPrimaryMonitor` should look like `{ name = "DP-3"; res = "1920x1080@200"; }`.
  Assertion: at least one of `enableRegreet` or `enableAutoLogin` must be true.

- `useSddm { enableHidpi ? false, waylandCompositor ? "weston" }`
  Enables SDDM on Wayland with the repo's theme override.

- `useXdgPortal { enableKdeSupport ? false, enableHyprlandSupport ? false, enableGtkSupport ? enableHyprlandSupport }`
  Enables `xdg-desktop-portal` and adds KDE, Hyprland, and/or GTK portals.

### `modules.desktop.defaultApps`

- `defaultApps.useDefaultApps {}`
  Turns on `xdg.mimeApps`.

- `defaultApps.useFirefox { mimeTypes ? [ "application/pdf" "application/xhtml+xml" "x-scheme-handler/http" "x-scheme-handler/https" ] }`
  Sets Firefox as default for the given MIME types.

- `defaultApps.useHaruna {}`
  Sets Haruna as default for the repo's built-in audio/video MIME list.

- `defaultApps.useKitty {}`
  Creates a hidden `kitty-shellscript.desktop` entry and associates shell-script MIME types with Kitty.

- `defaultApps.useLibreOffice {}`
  Sets LibreOffice components as defaults for a large built-in set of office/document MIME types.

- `defaultApps.usePeaZip {}`
  Sets PeaZip as default for a large built-in set of archive/package MIME types.

- `defaultApps.useVscode { mimeTypes ? [...] }`
  Sets VS Code as default for the given text/code/config MIME types.

### `modules.desktop.gtk.theme`

- `gtk.theme.usePapirusIcon { theme ? "Papirus-Dark" }`
  Configures Papirus icons in Home Manager GTK settings.
  Allowed values: `Papirus`, `Papirus-Dark`, `Papirus-Light`.

- `gtk.theme.useRosePine { variant ? "main", windowOpacity ? 0.85 }`
  Configures Rose Pine GTK theme and optional transparency CSS.
  Allowed variants: `main`, `moon`, `dawn`.

### `modules.desktop.qt.theme`

- `qt.theme.usePapirusIcon { theme ? "Papirus-Dark" }`
  Installs Papirus icons and configures Qt5/Qt6 icon themes through `qt5ct` and `qt6ct`.
  Allowed values: `Papirus`, `Papirus-Dark`, `Papirus-Light`.

- `qt.theme.useRosePine { variant ? "main", accent ? "rose", useOverlay ? true, kvantumTranslucentWindows ? true, kvantumBlurring ? true, kvantumPopupBlurring ? true, kvantumReduceWindowOpacity ? 12 }`
  Installs and configures the Rose Pine Kvantum theme, optionally via a local overlay that rewrites `.kvconfig` files.
  Allowed variants: `main`, `moon`, `dawn`.
  Allowed accents: `rose`, `pine`, `foam`, `gold`, `iris`, `love`.

### `modules.desktop.logind`

- `logind.useLogind {}`
  Sets lid and power-key behavior to suspend/lock.

### `modules.desktop.plasma6`

- `plasma6.usePlasma6 { overrideConfig ? false, excludePackages ? [], enableSddmIntegration ? true, persistPath ? null }`
  Enables Plasma 6, wires in `plasma-manager`, configures the user plasma module, optionally excludes Plasma packages, and optionally persists `/var/lib/sddm`.

#### `modules.desktop.plasma6.kwin`

- `plasma6.kwin.useBlur { strength ? 5 }`
  Enables KWin blur with the given strength.

- `plasma6.kwin.disableWindowBarrier {}`
  Disables corner and edge barriers.

#### `modules.desktop.plasma6.shortcuts`

- `plasma6.shortcuts.useGsrSaveReplay { key }`
  Maps the given key to `services/gsr-save-replay.desktop`.

- `plasma6.shortcuts.useKitty { key }`
  Maps the given key to `services/kitty.desktop`.

- `plasma6.shortcuts.useRestartWallpaper { key }`
  Maps the given key to `services/restart-wallpaper.desktop`.

#### `modules.desktop.plasma6.theme`

- `plasma6.theme.useLeaf {}`
  Installs the packaged Leaf KDE theme and sets the Plasma workspace look-and-feel to `leaf-dark`.

### `modules.desktop.hyprland`

- `hyprland.appearance { gapSize ? 5, borderSize ? 2, rounding ? 5, activeBorderColor ? "rgb(89b4fa)", inactiveBorderColor ? "rgb(585b70)", enableAnimations ? true, enableBlur ? true, activeOpacity ? 0.94, inactiveOpacity ? 0.86, fullscreenOpacity ? 1.0, blurSize ? 8, blurPasses ? 2 }`
  Applies the repo's default Hyprland window decoration, animation, dwindle, and scrolling settings.

- `hyprland.useAgs { agsPackage ? null, autostartCommand ? "ags run", enableAutostart ? true, layout ? null, package ? null, runtimePackages ? null }`
  Enables the `rflxn-shell` Home Manager module, configures `programs.ags-shell`, and starts `ags run` from Hyprland.
  Pass `layout` to render host-specific monitor/widget placement into the packaged shell config.

- `hyprland.useDarkMode { qtUseGtkPlatformTheme ? true }`
  Enables `dconf`, sets GNOME dark mode preference, and optionally exports `QT_QPA_PLATFORMTHEME=gtk3`.

- `hyprland.useHypridle { timeToScreenOff ? 600, timeToLock ? 900, timeToSuspend ? 1800 }`
  Enables Hypridle with DPMS off, lock, and suspend listeners.
  Note: the module currently hardcodes `600`, `900`, and `1800` in the listener list, so the declared arguments are currently no-ops.

- `hyprland.useHyprland { enableXWayland ? true, monitors ? null, workspaces ? null, followMouse ? 1, pointerSpeed ? 0, enableMouseAcceleration ? false, disableHardwareCursors ? false }`
  Enables Hyprland and UWSM, exports Wayland/IME session variables, starts `fcitx5`, and applies monitor/workspace/input settings.
  If a `hyprland` flake input is present in `specialArgs`, it uses that package and matching portal.

- `hyprland.useHyprlock {}`
  Enables Hyprlock with the repo's lock-screen theme and adds `hyprlock` PAM service.

- `hyprland.useHyprpolkit {}`
  Enables `hyprpolkitagent`.

- `hyprland.useHyprshell { modifier ? "alt" }`
  Enables Hyprshell, starts `hyprshell run`, and configures the window switcher.
  If a `hyprshell` flake input is present in `specialArgs`, it uses that package.

- `hyprland.useTrayBridge {}`
  Enables `snixembed`.

#### `modules.desktop.hyprland.cursors`

- `hyprland.cursors.useRosePineCursor { cursorSize ? 24 }`
  Configures Rose Pine cursor themes and Hyprcursor environment variables.

#### `modules.desktop.hyprland.keybinds`

- `hyprland.keybinds.useDefaults { mod ? "SUPER", subMod ? "SUPER SHIFT" }`
  Adds the repo's default Hyprland keybind pack, including workspace movement and the `hypr-smart-step` helper for tiled/floating resize and movement.

- `hyprland.keybinds.useAgsLauncher { key ? "SUPER, D" }`
  Binds `ags request launcher toggle`.

- `hyprland.keybinds.useAgsRestart { key ? "SUPER, backslash" }`
  Binds `ags quit; ags run`.

- `hyprland.keybinds.useKitty { key ? "SUPER, R" }`
  Binds `kitty`.

- `hyprland.keybinds.useGsrSaveReplay { key ? "ALT, F9" }`
  Binds `gsr-save-replay`.

- `hyprland.keybinds.useScreenOff { key ? "SUPER SHIFT, O", delaySeconds ? 1 }`
  Binds a delayed `hyprctl dispatch dpms toggle`.

- `hyprland.keybinds.useHyprshot { key ? "Print" }`
  Binds region capture to `Print` and active-window capture to `Alt+Print`.

- `hyprland.keybinds.useToggleMonitorSetup { settings ? [] }`
  Builds one toggle script per entry and binds each script to the configured key.
  Each entry should look like:

```nix
{
  monitorName = "eDP-1";
  defaultSetup = "eDP-1, 3456x2160@60, 0x0, 1.6";
  toggleSetup = "eDP-1, 3456x2160@120, 0x0, 1.6";
  key = "SUPER SHIFT, P";
}
```

#### `modules.desktop.hyprland.touchpad`

- `hyprland.touchpad.useDefaults {}`
  Applies the repo's touchpad defaults.

#### `modules.desktop.hyprland.touchpad.gestures`

- `hyprland.touchpad.gestures.useWorkspaces {}`
  Enables 3-finger horizontal workspace gestures.

#### `modules.desktop.hyprland.wallpaper`

- `hyprland.wallpaper.useHyprpaper { wallpaper ? null, monitors ? [], wallpapers ? [] }`
  Enables Hyprpaper using either one wallpaper plus `monitors`, or a `wallpapers` list.
  `wallpapers` entries should look like `{ monitor = "DP-3"; path = "/path/to/file"; }`.
  Assertion: one of the wallpaper forms must resolve to a non-empty config.

- `hyprland.wallpaper.useLinuxWallpaperEngine { wallpapers, fps ? 60 }`
  Starts Linux Wallpaper Engine via Hyprland `exec-once` and installs a restart helper.
  `wallpapers` entries should look like `{ screen = "DP-3"; wallpaper = "2798192282"; }`.
  Assertion: `wallpapers` must not be empty.

#### `modules.desktop.hyprland.windowRules`

- `hyprland.windowRules.useDefaults {}`
  Initializes `windowrule` with the repo's placeholder defaults.

- `hyprland.windowRules.useFixedSpotify { workspace }`
  Pins Spotify to a workspace by class match.

- `hyprland.windowRules.useFixedVesktop { workspace }`
  Pins Vesktop to a workspace by class match.

## `modules.programs`

### `modules.programs.gaming`

- `programs.gaming.useLsfgVk {}`
  Installs `lsfg-vk` and `lsfg-vk-ui`.

- `programs.gaming.useLutris {}`
  Installs Lutris.

- `programs.gaming.useProtonplus {}`
  Installs ProtonPlus.

- `programs.gaming.useR2modman {}`
  Installs `r2modman`.

- `programs.gaming.useSteam { enableGamescope ? false, enableProtontricks ? false }`
  Enables Steam, optionally enables Gamescope and Protontricks, and adds an `ananicy-cpp` rule for Gamescope.

- `programs.gaming.useWine { isWayland ? false }`
  Installs either Wayland Wine or the full X11-oriented Wine package set.

### `modules.programs.jetbrains`

- `programs.jetbrains.useIntellij { enableZshAlias ? false }`
  Installs IntelliJ IDEA and optionally defines an `idea()` zsh launcher function.

- `programs.jetbrains.usePycharm { enableZshAlias ? false }`
  Installs PyCharm Professional and optionally defines a `pycharm()` zsh launcher function.

- `programs.jetbrains.useWebstorm { enableZshAlias ? false }`
  Installs WebStorm and optionally defines a `webstorm()` zsh launcher function.

### `modules.programs.shell`

- `programs.shell.useShell {}`
  Adds Bash to `environment.shells` and sets `EDITOR=nano`.

- `programs.shell.useZsh {}`
  Enables system Zsh, sets the user shell to Zsh, enables Home Manager Zsh, `oh-my-zsh`, autosuggestions, syntax highlighting, and Powerlevel10k init content.

### Other `modules.programs` exports

- `useAyugram {}`
  Installs AyuGram Desktop.

- `useBlueman {}`
  Enables the Blueman D-Bus service and suppresses the default autostart desktop file.

- `useClaudeCode {}`
  Applies the Claude Code overlay, installs the package, configures the Home Manager module, and uses a runtime `npx` wrapper for the status line.

- `useCodex {}`
  Installs Codex CLI from the `codex-cli-nix` flake input.

- `useCodexDesktop {}`
  Installs Codex Desktop from the `codex-desktop` flake input.

- `useCommonTools {}`
  Installs the repo's common CLI toolkit.

- `useChrome {}`
  Installs Google Chrome.

- `useDirenv {}`
  Enables Home Manager Direnv with Bash, Zsh, and `nix-direnv` integration.

- `useDiscord {}`
  Installs a Vesktop variant with Wayland IME flags baked into the desktop entry.

- `useDolphin {}`
  Installs KDE Dolphin.

- `useFastfetch { beforeModules ? [], afterModules ? [] }`
  Installs Fastfetch and writes a JSON config with custom module lists prepended/appended around the repo default layout.

- `useFirefox { enableWidevine ? false }`
  Enables Firefox, optionally overlays `aarch64-widevine`, and sets `MOZ_GMP_PATH` when `enableWidevine = true`.

- `useForgeCode { enableZshIntegration ? false }`
  Builds and installs ForgeCode from `modules/programs/forge-code/pkg.nix`, installs helper tools, removes installer leftovers from `~/.bashrc`, and optionally injects ForgeCode Zsh integration.

- `useGit { name, email }`
  Enables Git and Git LFS in Home Manager, sets user identity and default branch, and enables GitHub CLI with credential helper.

- `useHaruna {}`
  Installs Haruna.

- `useHyprshot {}`
  Installs Hyprshot.

- `useKcalc { enableWindowsAlias ? false }`
  Installs KCalc and optionally creates a `calc` desktop entry alias.

- `useKitty {}`
  Installs Kitty and writes the repo's `kitty.conf` into Home Manager.

- `useKolourpaint { enableWindowsAlias ? false }`
  Installs KolourPaint and optionally creates a `pbrush` desktop entry alias.

- `useLact { enableDaemon ? true }`
  Installs LACT and optionally creates a simple systemd service that runs `lact daemon`.

- `useLibreOffice {}`
  Installs a wrapped `libreoffice-qt-fresh` package that forces the Qt6 VCL backend and avoids global Qt style overrides.

- `useMoonlight {}`
  Installs Moonlight Qt.

- `useNixIndex {}`
  Enables Home Manager `nix-index` with Bash and Zsh integration.

- `useNmApplet {}`
  Installs `networkmanagerapplet`.

- `useObsStudio { enableVirtualCamera ? false, enableAmdVaapi ? true, extraPlugins ? [] }`
  Enables OBS Studio with the repo's default plugin set and optional VAAPI/extra plugins.

- `usePeaZip {}`
  Installs PeaZip.

- `usePwvucontrol {}`
  Installs `pwvucontrol`.

- `useShotcut {}`
  Installs Shotcut.

- `useSpotify {}`
  Installs Spotify on most systems, or `spotify-qt` plus `librespot` on `aarch64-linux`. On `aarch64-linux`, it patches `spotify-qt.json` if that file already exists.

- `useT3 {}`
  Installs `t3code` from the flake input.

- `useThunar {}`
  Enables Thunar plus archive, GVFS, and tumbler support.

- `useVscode {}`
  Installs VS Code.

- `useWaylandUtils {}`
  Installs `wl-clipboard` and `wayland-utils`.

## `modules.services`

### `modules.services.nginx`

- `services.nginx.useNginX { upstreams ? {} }`
  Enables Nginx with the repo's recommended gzip, optimisation, and proxy settings.

#### `modules.services.nginx.vhosts`

- `services.nginx.vhosts.useDeluge { port ? 8112 }`
  Exposes Deluge under `/torrent`.

- `services.nginx.vhosts.useSyncthing { port ? 8384 }`
  Exposes Syncthing under `/syncthing` with custom proxy settings suited to Syncthing.

### `modules.services.pipewire`

- `services.pipewire.usePipewire {}`
  Enables PipeWire with ALSA, PulseAudio, JACK, and 32-bit ALSA support.

- `services.pipewire.useDenoisedMic {}`
  Adds an `rnnoise` filter-chain source called `Noise Canceling Source`.

- `services.pipewire.useLowLatency {}`
  Applies a fixed `48000 Hz` / `64 quantum` low-latency PipeWire config.

### Other `modules.services` exports

- `useBatteryLogger { logFile ? null, lockFile ? null, powerSupplyDir ? null, batteryDeviceName ? null }`
  Imports the `battery-logger` NixOS module and conditionally forwards the provided options.

- `useDocker { isBtrfs ? false, isRootless ? false, containersAsService ? {}, persistPath ? null }`
  Enables Docker, optionally uses the `btrfs` storage driver, optionally enables rootless mode, optionally defines `virtualisation.oci-containers`, and persists `/var/lib/docker` when a persistence path is available.
  `containersAsService` is passed through to `virtualisation.oci-containers.containers`.

- `useDeluge { authFile ? null, downloadDir ? null, webAuthFile ? null, webHost ? "0.0.0.0", webPort ? 8112, persistPath ? null }`
  Enables Deluge, writes `core.conf`, optionally installs `auth` and `web.conf` from secret files, and persists `/var/lib/deluge` when a persistence path is available.

- `useFlatpak { persistPath ? null }`
  Enables Flatpak and persists `/var/lib/flatpak` when a persistence path is available.

- `useGpuScreenRecorder { window ? "screen", framerate ? 60, replaySeconds ? 300, quality ? "high", container ? "mp4", audioSource ? "default_output", outputDir ? null }`
  Creates a user service for replay-mode GPU Screen Recorder, adds a `gsr-save-replay` helper, and allows the repo user through Polkit.

- `useHomeManager { stateVersion ? "25.11", backupCommand ? null }`
  Imports the Home Manager NixOS module, sets `useGlobalPkgs` and `useUserPackages`, enables `programs.home-manager`, and configures backup behavior.

- `useJetbrainsRemote { ides ? [] }`
  Enables Home Manager JetBrains Remote and forwards the `ides` list.

- `useKeyd { settings ? {} }`
  Enables Keyd and sets `services.keyd.keyboards = settings`.

- `useLibinput {}`
  Enables libinput.

- `useLinuxWallpaperengine { wallpapers, fps ? 60, bindToPlasma ? false }`
  Creates a user service for Linux Wallpaper Engine and installs a `restart-wallpaper` helper.
  `wallpapers` entries should look like `{ screen = "DP-3"; wallpaper = "2798192282"; }`.
  This is the systemd-service variant; `modules.desktop.hyprland.wallpaper.useLinuxWallpaperEngine` is the Hyprland `exec-once` variant.

- `useNginX { upstreams ? {} }`
  Alias for `services.nginx.useNginX`.

- `useRtkit {}`
  Enables realtime kit.

- `useSamba { directories ? {}, persistPath ? null }`
  Enables Samba with one share per entry in `directories`, forces ownership to the repo user and primary group, and persists `/var/lib/samba` when a persistence path is available.
  `directories` should look like `{ data = "/home/rflxn/data"; }`.
  Assertion: `directories` must not be empty.

- `useSsh { persistPath ? null, allowPasswordLogin ? false }`
  Enables OpenSSH, controls password auth, disables root login, and persists host keys when a persistence path is available.

- `useSyncthing { devices ? {}, folders ? {}, serviceLevel ? "user", webHost ? "0.0.0.0", webPort ? 8384, persistPath ? null }`
  Enables Syncthing either as a Home Manager user service or a NixOS system service depending on `serviceLevel`.
  `devices` and `folders` are passed through to Syncthing settings.
  `folders` entries should look like:

```nix
{
  development = {
    id = "development";
    path = "/home/rflxn/development";
    devices = [ "rflxn-server" ];
  };
}
```

  Note: `persistPath` only affects the system-service branch.

- `useTailscale { persistPath ? null, enableSystemTray ? false }`
  Enables Tailscale, optionally adds a user systray service with `--operator=${username}`, and persists `/var/lib/tailscale` when a persistence path is available.

- `useVscodeServer {}`
  Imports the `nixos-vscode-server` module and enables the service.

## Internal Helpers And Non-Exported Files

These files exist in the tree but are not part of the exported `modules` API:

- `modules/desktop/default-apps/utils.nix`
  Provides `mkMimeDefaults`.

- `modules/programs/forge-code/pkg.nix`
  Package derivation used by `useForgeCode`.

- `modules/desktop/plasma6/theme/leaf/leaf-pkg.nix`
  Package derivation used by `plasma6.theme.useLeaf`.

- `modules/services/nginx/vhosts/port-redirect-helper.nix`
  Shared reverse-proxy helper used by the built-in Deluge and Syncthing vhosts.

- `modules/system/boot/grub/theme/hyperfluent.nix`
  GRUB theme derivation, currently not exported from `modules.system.boot`.

## Current API Quirks

- `hyprland.useHypridle` declares timeout arguments but currently hardcodes the listener values.
- `services.useSyncthing.persistPath` only affects the `serviceLevel = "system"` branch.
- `services.useNginX` and `services.nginx.useNginX` are the same export surface.
