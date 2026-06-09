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
| `modules.system.boot.grub.theme.useDistroTheme` | `distro-grub-themes` |
| `modules.system.useImpermanence` | `impermanence` |
| `modules.desktop.plasma6.usePlasma6` | `plasma-manager` |
| `modules.desktop.hyprland.useAgs` | `rflxn-shell` |
| `modules.desktop.hyprland.useHyprland` | optional `hyprland` input, otherwise falls back to `pkgs.hyprland` |
| `modules.desktop.hyprland.useHyprshell` | optional `hyprshell` input, otherwise falls back to `pkgs.hyprshell` |
| `modules.programs.useClaudeCode` | `claude-code` |
| `modules.programs.useCodex` | `codex-cli-nix` |
| `modules.programs.useCodexDesktop` | `codex-desktop` |
| `modules.programs.useFirefox { enableWidevine = true; }` | optional `aarch64-widevine` on Asahi |
| `modules.programs.gaming.ffxiv.useXivMitmClientRoutes` / `useXivMitmGateway` | `xivmitm-nix` |
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
      keybind = { ... }; # alias of keybinds
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
    xdgPortal = {
      useHyprlandPortal = ...;
      useKdePortal = ...;
      useXdgPortal = ...;
    };
    useGreetd = ...;
    useSddm = ...;
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

- `boot.grub.useGrub { timeout ? null, configurationLimit ? 10, defaultEntry ? 0, gfxmodeEfi ? "auto", gfxpayloadEfi ? "keep", timeoutStyle ? "menu", useOSProber ? false }`
  Enables GRUB for UEFI systems with `device = "nodev"`, disables OS prober by default, and optionally configures timeout, retained configurations, default entry, EFI graphics mode/payload, and timeout style.

- `boot.grub.theme.useDistroTheme { name ? "nixos" }`
  Applies a `distro-grub-themes` theme to GRUB by name.

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

- `useImpermanence { rootUuid, persistPath ? null, directories ? [], files ? [], enableWipeRoot ? true }`
  Enables impermanence, optionally resets `@root` from `@root-blank` during initrd, writes wipe-root diagnostics to `/persist/log/wipe-root.log` when `@persist` exists, persists `/home`, logs, `machine-id`, and any extra directories/files provided.

- `useMe { hashedPassword ? null, hashedPasswordFile ? null, rootHashedPassword ? null, rootHashedPasswordFile ? null, extraGroups ? [] }`
  Creates the main user from `username`, disables mutable users, adds `wheel`, accepts either an inline hash or a password-hash file, and can optionally set the root password for emergency access.

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

- `useGreetd { enableRegreet ? false, regreetCompositor ? "hyprland", regreetPrimaryMonitor ? null, enableAutoLogin ? false, autoLoginSession ? "uwsm-hyprland", enableSilentSession ? enableAutoLogin }`
  Enables `greetd` for either Regreet or autologin.
  `enableSilentSession` clears the text console and redirects the greetd-launched session command output to the journal instead of tty output.
  `regreetPrimaryMonitor` should look like `{ name = "DP-3"; res = "1920x1080@200"; }`.
  Assertion: at least one of `enableRegreet` or `enableAutoLogin` must be true.

- `useSddm { enableHidpi ? false, waylandCompositor ? "weston" }`
  Enables SDDM on Wayland with the repo's theme override.

### `modules.desktop.xdgPortal`

- `xdgPortal.useXdgPortal {}`
  Enables `xdg-desktop-portal`.

- `xdgPortal.useHyprlandPortal { useQtTheme ? false, enableGtkFallback ? true }`
  Configures Hyprland as the portal backend with GTK fallback.
  When `useQtTheme` is true, KDE's portal is installed and the file chooser portal is routed to KDE so Qt/Kvantum themed dialogs can be used.

- `xdgPortal.useKdePortal {}`
  Adds KDE's portal backend.

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

- `gtk.theme.useMatcha { color ? "dark", variant ? "azul", windowOpacity ? 0.85 }`
  Configures Matcha GTK theme and optional transparency CSS.
  Allowed colors: `standard`, `light`, `dark`.
  Allowed variants: `aliz`, `azul`, `pueril`, `sea`.

- `gtk.theme.usePapirusIcon { theme ? "Papirus-Dark" }`
  Configures Papirus icons in Home Manager GTK settings.
  Allowed values: `Papirus`, `Papirus-Dark`, `Papirus-Light`.

- `gtk.theme.useRosePine { variant ? "main", windowOpacity ? 0.85 }`
  Configures Rose Pine GTK theme and optional transparency CSS.
  Allowed variants: `main`, `moon`, `dawn`.

### `modules.desktop.qt.theme`

- `qt.theme.useMatcha { color ? "dark", kvantumTranslucentWindows ? true, kvantumBlurring ? true, kvantumPopupBlurring ? true, kvantumReduceWindowOpacity ? 12 }`
  Packages `vinceliuice/Matcha-kde`, installs Qt/Kvantum support, and configures Qt5/Qt6 to use the Matcha Kvantum theme.

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

- `hyprland.useAgs { agsPackage ? null, autostartCommand ? "ags run", enableAutostart ? true, layout ? null, notificationPopups ? null, package ? null, runtimePackages ? null, systemControlMenu ? {} }`
  Enables the `rflxn-shell` Home Manager module, configures `programs.ags-shell`, and starts `ags run` from Hyprland. `notificationPopups` is forwarded to the shell's popup placement and queue configuration.
  Pass `layout` to render host-specific monitor/widget placement into the packaged shell config.

- `hyprland.useDarkMode { qtUseGtkPlatformTheme ? true }`
  Enables `dconf`, sets GNOME dark mode preference, and optionally exports `QT_QPA_PLATFORMTHEME=gtk3`.

- `hyprland.useHypridle { timeToScreenOff ? 600, timeToLock ? 900, timeToSuspend ? 1800 }`
  Enables Hypridle with DPMS off, lock, and suspend listeners.
  Note: the module currently hardcodes `600`, `900`, and `1800` in the listener list, so the declared arguments are currently no-ops.

- `hyprland.useHyprland { enableXWayland ? true, monitors ? null, workspaces ? null, followMouse ? 1, pointerSpeed ? 0, enableMouseAcceleration ? false, disableHardwareCursors ? false, noCursorWarps ? true }`
  Enables Hyprland and UWSM, exports Wayland/IME session variables, starts `fcitx5`, and applies monitor/workspace/input/cursor settings.
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

- `hyprland.keybinds.useMediaFunctions { enableMicMute ? true, enableStop ? true, maxVolume ? "1.0", playerctlPackage ? null, sink ? "@DEFAULT_AUDIO_SINK@", source ? "@DEFAULT_AUDIO_SOURCE@", volumeStep ? "5%", wireplumberPackage ? null }`
  Binds standard media function keys with `wpctl` and `playerctl`. `hyprland.keybind.useMediaFunctions` is available as a singular alias.

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

- `hyprland.windowRules.useFixedDiscord { workspace }`
  Pins Discord to a workspace by class match.

- `hyprland.windowRules.useFixedSpotify { workspace }`
  Pins Spotify to a workspace by class match.

- `hyprland.windowRules.useFixedMopiMopi { workspace }`
  Pins MopiMopi to a workspace by class match.

- `hyprland.windowRules.useFixedVesktop { workspace }`
  Pins Vesktop to a workspace by class match.

## `modules.programs`

### `modules.programs.gaming`

- `programs.gaming.useLsfgVk {}`
  Installs `lsfg-vk` and `lsfg-vk-ui`.

- `programs.gaming.useLutris {}`
  Installs Lutris.

- `programs.gaming.useMangoHud { enableSessionWide ? false, settings ? {}, settingsPerApplication ? {} }`
  Enables Home Manager's MangoHud module, writes MangoHud config from `settings`, and adds MangoHud to Steam's FHS environment.

- `programs.gaming.useProtonplus {}`
  Installs ProtonPlus.

- `programs.gaming.useR2modman {}`
  Installs `r2modman`.

- `programs.gaming.useSteam { enableGamescope ? false, enableProtontricks ? false }`
  Enables Steam, optionally enables Gamescope and Protontricks, and adds an `ananicy-cpp` rule for Gamescope.

- `programs.gaming.useWine { isWayland ? false }`
  Installs either Wayland Wine or the full X11-oriented Wine package set.

#### `modules.programs.gaming.ffxiv`

- `programs.gaming.ffxiv.useCactbot {}`
  Installs Chromium webapp launchers for `Cactbot - Raidboss` and `Cactbot - Configuration`.

- `programs.gaming.ffxiv.useFFXIV { enableFileSecret ? false, enableDotNetIPv6 ? true }`
  Installs `xivlauncher-rb`; when needed, patches its desktop entry to launch with `XL_SECRET_PROVIDER=file` and/or `DOTNET_SYSTEM_NET_DISABLEIPV6=1`.

- `programs.gaming.ffxiv.useMopiMopi {}`
  Installs a `mopimopi` launcher package with a desktop entry that opens the MopiMopi overlay in Chromium.

- `programs.gaming.ffxiv.useXivMitmClientRoutes { gateway, interface, ranges ? null }`
  Wraps `xivmitm-nix.nixosModules.client` and enables client-side FFXIV routes through the given gateway/interface.

- `programs.gaming.ffxiv.useXivMitmGateway { listenPort ? 10514, incomingInterface ? null, outgoingInterface ? incomingInterface, clientCidr ? null, portRange ? "1024:65535", ranges ? null, manageDocker ? false, runContainer ? false, ... }`
  Wraps `xivmitm-nix.nixosModules.server` and enables server-side sysctls and iptables routing for XivMitmLatencyMitigator. Docker container management stays disabled by default for raw Compose usage.

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

- `useCodexDesktop { codexDmgHash ? null, codexDmgUrl ? "https://persistent.oaistatic.com/codex-app-prod/Codex.dmg", package ? null }`
  Enables the upstream Codex Desktop Linux Home Manager module from the `codex-desktop` flake input. `codexDmgHash` can temporarily override the upstream `Codex.dmg` fixed-output hash when the upstream package lags a release.

- `useCommonTools {}`
  Installs the repo's common CLI toolkit.

- `useChrome {}`
  Installs Google Chrome.

- `useDirenv {}`
  Enables Home Manager Direnv with Bash, Zsh, and `nix-direnv` integration.

- `useDiscord {}`
  Installs the stock Discord package with an XWayland/fcitx desktop entry for stable IME behavior.

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

- `useGptOauthServer { host ? "0.0.0.0", port ? 10531, version ? "1.0.1", authFile ? null, models ? null, codexVersion ? null, baseUrl ? null, oauthClientId ? null, oauthTokenUrl ? null, extraArgs ? [] }`
  Installs a `gpt-server` wrapper that runs `npx --yes openai-oauth@${version}` with the configured defaults and forwards extra runtime arguments.

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

- `useSshClient { settings ? {}, enableDefaultConfig ? false }`
  Enables Home Manager SSH client config and writes OpenSSH blocks to `programs.ssh.settings`.
  When `enableDefaultConfig = false`, it writes the Home Manager legacy `Host *` defaults explicitly.

- `useSpotify {}`
  Installs Spotify on most systems, or `spotify-qt` plus `librespot` on `aarch64-linux`. On `aarch64-linux`, it patches `spotify-qt.json` if that file already exists.

- `useTauon {}`
  Installs Tauon.

- `useThunderbird { package ? null }`
  Enables Thunderbird through the NixOS `programs.thunderbird` module.

- `useThunar {}`
  Enables Thunar plus archive, GVFS, and tumbler support.

- `useVesktop {}`
  Installs a Vesktop variant with Wayland IME flags baked into the desktop entry.

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
