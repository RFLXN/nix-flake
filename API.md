# Module API

Reference for the module API exported under `./modules`.

This document covers the repository-local module surface rather than upstream NixOS or Home Manager options.

## Usage Model

Most reusable modules are two-stage curried functions:

```nix
{ optionA ? defaultA, ... }:
{ pkgs, lib, username, ... }:
{ ... }
```

Typical host usage:

```nix
{ modules, ... }: {
  imports = with modules.system; [
    (boot.useSystemdBoot {})
    (useMe { hashedPasswordFile = "/persist/secrets/rflxn.hashedPassword"; })
  ];
}
```

## Cross-Cutting Requirements

- Most desktop and program modules configure `home-manager.users.${username}` and assume `modules.services.useHomeManager {}` is imported by the host.
- Persistence-aware modules write state to `persistPath` when explicitly passed, or fall back to the `defaultPersistPath` special argument. Hosts must provide `defaultPersistPath` (currently `"/persist"`); because second-stage module arguments cannot use fallback defaults for `specialArgs`, referencing a missing special argument triggers an evaluation error.
- Many modules expect `username` to be provided via `specialArgs`.
- Several modules require specific flake inputs to be passed through host `specialArgs`.
- Hyprland modules that take the `hyprLua` helper require `modules.desktop.hyprland.useHyprland` in the same host, which injects `_module.args.hyprLua`. This applies to all `hyprland.keybinds.*` exports, `hyprland.useHyprlock`, `hyprland.useHyprshell`, `hyprland.wallpaper.useLinuxWallpaperEngine`, and `hyprland.windowRules.useHidden`.

Modules requiring flake inputs in `specialArgs`:

| Module | Required special arg |
| --- | --- |
| `modules.system.boot.useLanzaboote` | `lanzaboote` |
| `modules.system.boot.grub.theme.useDistroTheme` | `distro-grub-themes` |
| `modules.system.useImpermanence` | `impermanence` |
| `modules.desktop.hyprland.useDankLinux` | `dank-material-shell` |
| `modules.desktop.hyprland.useHyprland` | optional `hyprland` input (read from `specialArgs`); falls back to `pkgs.hyprland` |
| `modules.desktop.hyprland.useHyprshell` | optional `hyprshell` input; falls back to `pkgs.hyprshell` |
| `modules.programs.useClaudeCode` | `claude-code` |
| `modules.programs.useClaudeDesktop` | `claude-desktop` |
| `modules.programs.useAntigravity` | `antigravity-nix` |
| `modules.programs.useCodex` | `codex-cli-nix` |
| `modules.programs.useCodexDesktop` | `codex-desktop` |
| `modules.programs.useFirefox { enableWidevine = true; }` | `aarch64-widevine` (only evaluated when `enableWidevine = true`) |
| `modules.programs.gaming.ffxiv.useFFXIV` | `xivlauncher-rb` |
| `modules.programs.gaming.ffxiv.useXivMitmClientRoutes` / `useXivMitmGateway` | `xivmitm-nix` |
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
    qt = {
      theme = { ... };
      useDolphinQtTheme = ...;
    };
    xdgPortal = {
      useHyprlandPortal = ...;
      useXdgPortal = ...;
    };
    useGreetd = ...;
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
  Enables UEFI GRUB (`device = "nodev"`), disables OS prober by default, and configures the boot timeout, generation retention limit, default entry, EFI graphics mode and payload, and timeout style.

- `boot.grub.theme.useDistroTheme { name ? "nixos" }`
  Applies the `<name>-grub-theme` package from `distro-grub-themes` to GRUB and sets `boot.loader.grub.splashImage` to the theme's `splash_image.jpg`.
  Assertion: `distro-grub-themes` must provide `<name>-grub-theme` for the target system.

- `boot.useLanzaboote { persistPath ? null }`
  Enables Lanzaboote, disables direct `systemd-boot`, installs `sbctl`, and persists `/var/lib/sbctl`.
  Not currently imported by any host, as Secure Boot is not in use.

- `boot.usePlymouth { theme ? "breeze", enableQuietBoot ? true }`
  Enables Plymouth. When `enableQuietBoot` is enabled, sets `boot.consoleLogLevel = 0` and adds the `quiet`, `udev.log_level=0`, and `systemd.show_status=false` kernel parameters.

- `boot.useSystemdBoot { consoleMode ? null, configurationLimit ? 15 }`
  Enables `boot.loader.systemd-boot` and optionally configures the console mode and generation retention limit.

### `modules.system.nix`

- `nix.useCache {}`
  Adds the `claude-code.cachix.org` binary cache and its public key (`cache.nixos.org` remains enabled via the NixOS default).

- `nix.useExperimentalFeatures {}`
  Enables the `nix-command` and `flakes` experimental features.

- `nix.useGc { dates, options ? "--delete-older-than 30d" }`
  Enables automatic garbage collection on the specified `dates` schedule. `options` is passed to `nix-collect-garbage`: the default removes profile generations older than 30 days, whereas `""` collects only unreferenced store paths.

- `nix.useOptimise { dates }`
  Enables automatic Nix store optimization on the specified `dates` schedule.

- `nix.useUnfreePackage {}`
  Sets `nixpkgs.config.allowUnfree = true`.

### Other `modules.system` exports

- `useCjkFonts {}`
  Installs and configures the repository's default Latin, Korean, and Japanese fonts, including custom `fontconfig` language priority rules.

- `useFcitx5 {}`
  Enables `fcitx5` with the GTK, Hangul, and Mozc addons.

- `useFirewall { trustedInterfaces ? [] }`
  Enables the NixOS stateful firewall and trusts all incoming traffic on the specified interfaces.

- `useImpermanence { rootUuid, persistPath ? null, directories ? [], files ? [], enableWipeRoot ? true }`
  Enables `impermanence` and persists `/home`, `/var/log`, `/var/lib/nixos`, `/var/lib/systemd/coredump`, `/var/lib/systemd/timers`, `/etc/machine-id`, plus any extra `directories` and `files`.
  When `enableWipeRoot` is true, an initrd service resets `@root` from `@root-blank` on boot and logs diagnostics to `/persist/log/wipe-root.log` on the root filesystem's `@persist` subvolume (`rootUuid`), regardless of `persistPath`. Rather than deleting the previous `@root` immediately, it moves the subvolume to `old_roots/<timestamp>` at the Btrfs top level and prunes snapshots older than 30 days. If `@root-blank` is absent, the existing `@root` is left intact.
  Persisting `/var/lib/systemd/timers` preserves last-run timestamps for `Persistent=true` timers (such as `nix.gc` and `nix.optimise`) so missed schedules catch up after boot. The root-wipe unit is ordered after `systemd-hibernate-resume.service` so waking from hibernation resumes normally instead of wiping the root subvolume.

- `useMe { hashedPassword ? null, hashedPasswordFile ? null, rootHashedPassword ? null, rootHashedPasswordFile ? null, extraGroups ? [] }`
  Creates the primary user account (`username`) with `wheel` access, disables mutable users, accepts either an inline password hash or a hash file, and optionally configures the `root` password for emergency recovery.

- `useNetworkManager { useWifi ? false, persistPath ? null }`
  Enables NetworkManager with `dns = "none"`, adds the primary user to the `networkmanager` group, and persists `/var/lib/NetworkManager` and `/etc/NetworkManager/system-connections`. Because NetworkManager does not manage `resolv.conf` in this setup, the host must configure DNS separately (e.g., via `networking.nameservers`).
  When `useWifi = true`, enables `iwd` as the Wi-Fi backend, disables Wi-Fi power saving, and additionally persists `/var/lib/iwd`. `iwd` handles wireless association while NetworkManager continues to manage IP addressing and routing.

- `useNtSync {}`
  Loads the `ntsync` kernel module at boot (`boot.kernelModules`) for Wine/Proton NT synchronization primitives.

- `useZram { memoryPercent ? 25, priority ? 10 }`
  Enables zram swap with the specified memory percentage and swap priority.

## `modules.hardware`

- `useAmdGpu { enableOverdrive ? false }`
  Loads `amdgpu` in the initrd (`hardware.amdgpu.initrd.enable`), sets the X11 video driver to `amdgpu`, and optionally enables AMD overdrive. Does not enable `hardware.graphics` on its own; import `useGraphics` alongside it.

- `useBluetooth { persistPath ? null }`
  Enables Bluetooth (with `Experimental`, `FastConnectable`, and power-on-boot enabled), enables `upower`, and persists `/var/lib/bluetooth`.

- `useGraphics { enable32Bit ? null }`
  Enables `hardware.graphics`. Leaving `enable32Bit = null` enables 32-bit graphics support on `x86_64` only; pass an explicit boolean to override.

- `useOpenrazer {}`
  Enables OpenRazer and adds the primary user to the `openrazer` group.

## `modules.desktop`

### Top-level exports

- `useGreetd { enableRegreet ? false, regreetCompositor ? "hyprland", regreetPrimaryMonitor ? null, enableAutoLogin ? false, autoLoginSession ? "uwsm-hyprland", enableSilentSession ? enableAutoLogin }`
  Configures `greetd` for either Regreet or automatic login. If both are enabled, autologin takes precedence and Regreet is bypassed, leaving `regreetCompositor` and `regreetPrimaryMonitor` unused.
  Autologin intentionally skips a greeter so the desktop shell's own lock screen (such as DMS with `lockAtStartup`) serves as the initial authentication prompt. Because the autologin command is wired to both `initial_session` and `default_session` with `services.greetd.restart` enabled, logging out or restarting `greetd` immediately starts a new session.
  Note that the first login after boot (`initial_session`) runs as a standard `logind` user session and supports `logind` lock integration (`loginctl lock-session`, lid-close locking, and shell lock hooks). Subsequent logins after a logout run through `default_session`, which `greetd` registers under the `greeter` session class and therefore cannot be locked via `logind` until the next reboot.
  `autoLoginSession` accepts `"uwsm-hyprland"`, `"hyprland"`, or a custom session command string. `enableSilentSession` wraps the built-in `"uwsm-hyprland"` and `"hyprland"` commands to clear the TTY and route output to the systemd journal via `systemd-cat`; custom session strings and Regreet are not wrapped.
  `regreetCompositor` accepts `"hyprland"`, `"cage"`, or a custom compositor command. The `"hyprland"` option launches `Hyprland -c /etc/greetd/hyprland.lua` (generated as Lua) and expects Hyprland to be installed by another module. `regreetPrimaryMonitor` (e.g., `{ name = "DP-3"; res = "1920x1080@200"; }`) applies only when `regreetCompositor = "hyprland"` and disables all other outputs while the greeter is active.
  Assertion: at least one of `enableRegreet` or `enableAutoLogin` must be true.

### `modules.desktop.xdgPortal`

- `xdgPortal.useXdgPortal {}`
  Enables `xdg-desktop-portal` without registering a backend. Because NixOS requires `xdg.portal.extraPortals` to be non-empty, pair this with a backend module such as `useHyprlandPortal`.
  Note: unlike most modules in this repository, its second stage is a plain attribute set rather than a function, which remains a valid NixOS module.

- `xdgPortal.useHyprlandPortal { useQtTheme ? false, enableGtkFallback ? true }`
  Configures Hyprland as the primary XDG desktop portal backend with an optional GTK fallback (`default = [ "hyprland" "gtk" ]`).
  This module only adds the Hyprland and GTK portal packages itself when `programs.hyprland.enable` is false, since the NixOS Hyprland module otherwise installs them automatically.
  When `useQtTheme = true`, installs the KDE portal and routes the file-chooser interface through KDE so file dialogs respect Qt/Kvantum theming.

### `modules.desktop.defaultApps`

- `defaultApps.useDefaultApps {}`
  Enables `xdg.mimeApps` in Home Manager.

- `defaultApps.useFirefox { mimeTypes ? [ "application/pdf" "application/xhtml+xml" "x-scheme-handler/http" "x-scheme-handler/https" ] }`
  Registers Firefox as the default handler for the specified MIME types.

- `defaultApps.useHaruna {}`
  Registers Haruna as the default player for the repository's built-in list of audio and video MIME types.

- `defaultApps.useKitty {}`
  Installs a hidden `kitty-shellscript.desktop` entry (`kitty sh <file>`) and registers it as the default handler for shell scripts, executing scripts in a Kitty terminal rather than opening them in an editor.

- `defaultApps.useLibreOffice {}`
  Registers LibreOffice applications as the default handlers for common office and document MIME types.

- `defaultApps.usePeaZip {}`
  Registers PeaZip (`peazip-extract.desktop`) as the default handler for common archive and package MIME types.

- `defaultApps.useVscode { mimeTypes ? [...] }`
  Registers VS Code as the default editor for the specified text, source code, and configuration MIME types.

### `modules.desktop.gtk.theme`

- `gtk.theme.useMatcha { color ? "dark", variant ? "azul", windowOpacity ? 0.85 }`
  Configures the Matcha GTK theme and optional window-transparency CSS.
  Allowed `color` values: `standard`, `light`, `dark`.
  Allowed `variant` values: `aliz`, `azul`, `pueril`, `sea`.
  Assertion: `windowOpacity` must be between `0.0` and `1.0` (transparency CSS is only generated when `< 1.0`).

- `gtk.theme.usePapirusIcon { theme ? "Papirus-Dark" }`
  Configures the Papirus icon theme in Home Manager GTK settings.
  Allowed values: `Papirus`, `Papirus-Dark`, `Papirus-Light`.

### `modules.desktop.qt`

- `qt.useDolphinQtTheme { colorScheme ? "*" }`
  Configures Dolphin's Qt/KDE color scheme via Home Manager. The default `"*"` wildcard defers to the active Qt theme's color scheme.

#### `modules.desktop.qt.theme`

- `qt.theme.useMatcha { color ? "dark", kvantumTranslucentWindows ? true, kvantumBlurring ? true, kvantumPopupBlurring ? true, kvantumReduceWindowOpacity ? 12 }`
  Packages `vinceliuice/Matcha-kde`, installs `qt6ct` and the Qt6 Kvantum style plugin, and configures Qt6 to use the Matcha `sea` Kvantum theme (`Matcha-sea` or `Matcha-sea-dark`; there is no `variant` option, and Qt5 is not configured).
  Sets `QT_QPA_PLATFORMTHEME=qt6ct` and `QT_STYLE_OVERRIDE=kvantum` across the system environment, Home Manager session variables, and systemd user manager, and writes the matching palette into `kdeglobals`. Because these environment variables are defined without priority overrides, combining this module with another module that sets them differently (such as `hyprland.useDarkMode` with its default `qtUseGtkPlatformTheme = true`) causes an evaluation conflict rather than a silent override.
  Allowed `color` values: `light`, `dark` (`standard` is not supported here, unlike `gtk.theme.useMatcha`; any other value fails evaluation).
  Assertion: `kvantumReduceWindowOpacity` must be between `0` and `100`.

- `qt.theme.usePapirusIcon { theme ? "Papirus-Dark" }`
  Installs the Papirus icon theme and configures it for both Qt5 and Qt6 via `qt5ct` and `qt6ct`.
  Allowed values: `Papirus`, `Papirus-Dark`, `Papirus-Light`.

- `qt.theme.useRosePine { variant ? "main", accent ? "rose", useOverlay ? true, kvantumTranslucentWindows ? true, kvantumBlurring ? true, kvantumPopupBlurring ? true, kvantumReduceWindowOpacity ? 12 }`
  Installs and configures the Rosé Pine Kvantum theme, optionally applying a system-wide `nixpkgs` overlay that patches `.kvconfig` files with the `kvantum*` settings (when `useOverlay = false`, the four `kvantum*` arguments have no effect).
  Allowed `variant` values: `main`, `moon`, `dawn`.
  Allowed `accent` values: `rose`, `pine`, `foam`, `gold`, `iris`, `love`.
  Assertion: `kvantumReduceWindowOpacity` must be between `0` and `100`, and invalid `variant` or `accent` values fail evaluation.

### `modules.desktop.logind`

- `logind.useLogind {}`
  Configures `logind` so pressing the power key suspends the system and closing the lid locks the session (on battery, on AC power, and while docked) without suspending.

### `modules.desktop.hyprland`

- `hyprland.appearance { gapSize ? 5, borderSize ? 2, rounding ? 5, activeBorderColor ? "rgb(89b4fa)", inactiveBorderColor ? "rgb(585b70)", enableAnimations ? true, enableBlur ? true, activeOpacity ? 0.94, inactiveOpacity ? 0.86, fullscreenOpacity ? 1.0, blurSize ? 8, blurPasses ? 2 }`
  Applies the repository's default Hyprland window decoration, animation, dwindle, and scrolling layout settings.

- `hyprland.useDankLinux { batteryChargeLimit ? null, lockScreenPasswordField ? null, package ? null, session ? {}, settings ? {}, systemdTarget ? null, theme ? null }`
  Enables DankMaterialShell (DMS) via Home Manager and declaratively manages its configuration. The `dms` user service always runs with `DMS_DISABLE_POLKIT=1` so DMS does not act as a polkit agent (use `hyprland.useHyprpolkit` instead).
  - `batteryChargeLimit`: Accepts an integer from `50` to `100` (or `null` to leave hardware limits unmanaged). Sets DMS's `settings.batteryChargeLimit` and enables the `dms-battery-charge-limit` system oneshot service, which applies the threshold at boot and whenever the value changes during `nixos-rebuild switch`. The helper discovers batteries via sysfs (including `macsmc-battery`), writes to `charge_control_end_threshold` or `charge_stop_threshold`, and verifies the applied value. Batteries without either sysfs node are skipped; the service fails only if no supported battery is found or if a threshold cannot be verified (attempting to restore prior limits on failure). Failed runs retry every 10 seconds up to six times to accommodate late-probing drivers. Check status via `journalctl -u dms-battery-charge-limit`. This mechanism relies purely on native kernel/hardware thresholds without patching the DMS UI or running a userspace polling loop.
  - `session`: Declaratively manages DMS session state (such as wallpaper paths) in `~/.local/state/dms/session.json`.
  - `theme`: Writes the provided attribute set to `~/.config/dms/themes/<id>/theme.json` (where `<id>` is `theme.id`; missing `id` fails evaluation) and overrides `settings.currentThemeName` and `settings.customThemeFile` to point to that file.
  - `lockScreenPasswordField`: When non-null, patches DMS's `LockAuthWidget.qml` (split out from `LockScreenContent.qml` in DMS 1.7) to customize the password input row's `width`, `height`, `radius`, `backgroundColor`, `backgroundOpacity`, `borderColor`, `focusBorderColor`, and `showLockIcon`. Only the input field row itself is modified, leaving the surrounding ring, avatar, feedback row, screen-width constraints, and style-dependent visibility untouched. Any non-null attribute set patches all eight properties, filling omitted keys from module defaults (`width = 380`, `height = 60`, `radius = 18`, `backgroundColor = "#181818"`, `backgroundOpacity = 0.9`, `borderColor = "#ffffff"`, `focusBorderColor = "#ffffff"`, `showLockIcon = true`) rather than upstream defaults. `width` and `height` must be positive numbers, `radius` non-negative, `backgroundOpacity` between `0` and `1`, colors strings, and `showLockIcon` a boolean. The build fails loudly if upstream QML expressions change.

- `hyprland.useDarkMode { qtUseGtkPlatformTheme ? true }`
  Enables `dconf`, sets the GNOME dark color-scheme preference, and optionally exports `QT_QPA_PLATFORMTHEME=gtk3`.

- `hyprland.useHypridle { timeToScreenOff ? 600, timeToLock ? 900, timeToSuspend ? 1800 }`
  Enables Hypridle with listeners for turning off displays (DPMS), locking the session, and suspending the system.

- `hyprland.useHyprland { enableXWayland ? true, monitors ? null, workspaces ? null, followMouse ? 1, pointerSpeed ? 0, enableMouseAcceleration ? false, disableHardwareCursors ? false, noCursorWarps ? true }`
  Enables Hyprland and UWSM, generates `hyprland.lua` via Home Manager, exports Wayland and IME session variables, launches `fcitx5`, and configures monitors, workspaces, input, and cursors.
  `monitors` takes a list of `hl.monitor` attribute sets (e.g., `{ output = "DP-3"; mode = "1920x1080@200"; position = "0x0"; scale = 1; }`).
  `workspaces` takes a list of `hl.workspace_rule` attribute sets (e.g., `{ workspace = "1"; monitor = "DP-3"; default = true; persistent = true; layout = "master"; }`).
  Uses the `hyprland` flake input and its matching portal when present in `specialArgs`, and sets `services.xserver.enable = enableXWayland` (enabled by default).
  Injects the `hyprLua` helper (`modules/desktop/hyprland/lua-helpers.nix`) into `_module.args` for companion modules.

- `hyprland.useHyprlock {}`
  Enables Hyprlock with the repository's lock-screen theme, registers the `hyprlock` PAM service, and triggers `hyprlock` one second after Hyprland starts so new sessions begin locked.

- `hyprland.useHyprpolkit {}`
  Enables `hyprpolkitagent`.

- `hyprland.useHyprshell { modifier ? "alt" }`
  Enables Hyprshell, starts `hyprshell run`, and configures the window switcher (using the `hyprshell` flake input when present in `specialArgs`).

- `hyprland.useTrayBridge {}`
  Enables `snixembed`.

- `hyprland.useXdgMenu { prefix ? "hyprland-" }`
  Sets `XDG_MENU_PREFIX` and generates an XDG applications menu so non-Plasma sessions can resolve desktop entries and "Open With" associations.

- `hyprland.useXdgUserDirs { createDirectories ? true }`
  Enables Home Manager XDG user directories, exports their session variables, and optionally creates the standard `Desktop`, `Documents`, `Downloads`, `Music`, `Pictures`, and `Videos` directories.

#### `modules.desktop.hyprland.cursors`

- `hyprland.cursors.useRosePineCursor { cursorSize ? 24 }`
  Configures Rosé Pine cursor themes and exports Hyprcursor environment variables.

#### `modules.desktop.hyprland.keybinds`

`key` arguments follow Hyprlang's `"MODS, key"` format (e.g., `"SUPER SHIFT, O"`); a string without a comma (e.g., `"F9"`) binds a bare key with no modifiers.
Helper scripts invoke `hyprctl` from `config.programs.hyprland.package` so they always match the active Hyprland build.

- `hyprland.keybinds.useDefaults { mod ? "SUPER", subMod ? "SUPER SHIFT", workspaceCount ? 7, moveWorkspaceCount ? workspaceCount }`
  Installs the default Hyprland keybind set, including workspace switching/movement and the `hypr-smart-step` helper for moving and resizing tiled or floating windows.
  `mod + 1..workspaceCount` switches to a workspace, and `subMod + 1..moveWorkspaceCount` moves the focused window to a workspace (both counts must be integers from `0` to `9`).
  `hypr-smart-step` steps window position or size by 5% of the focused monitor's effective dimensions (accounting for scale and rotation), falling back to `splitratio` adjustments only on `dwindle` workspaces when a resize is a no-op. `mod + mouse wheel` scrolls columns on `scrolling` workspaces and is ignored on other layouts.

- `hyprland.keybinds.useDankLinuxLauncher { key ? "SUPER, D", package ? null }`
  Binds the DankMaterialShell spotlight launcher (`spotlight toggle` IPC call). When `package = null`, reuses the package configured by `hyprland.useDankLinux` (including any lock-screen patch), requiring `useDankLinux` to be imported alongside it.

- `hyprland.keybinds.useKitty { key ? "SUPER, R" }`
  Binds `kitty`.

- `hyprland.keybinds.useGsrSaveReplay { key ? "ALT, F9" }`
  Binds `gsr-save-replay`.

- `hyprland.keybinds.useAudioModeToggle { key ? "SUPER, A" }`
  Binds `audio-mode toggle` (provided by `services.pipewire.useAudioModes`).

- `hyprland.keybinds.useScreenOff { key ? "SUPER SHIFT, O", delaySeconds ? 1 }`
  Binds a delayed Lua `hl.dsp.dpms` toggle to turn displays off or on.

- `hyprland.keybinds.useHyprshot { key ? "Print" }`
  Binds region screenshot capture to `<key>` and active-window capture to `Alt+<key>` (defaulting to `Print` and `Alt+Print`). Captures are copied directly to the clipboard without saving files to disk. Note that `key` takes a bare key name here; the module supplies the modifiers.

- `hyprland.keybinds.useMediaFunctions { enableMicMute ? true, enableStop ? true, maxVolume ? "1.0", playerctlPackage ? null, sink ? "@DEFAULT_AUDIO_SINK@", source ? "@DEFAULT_AUDIO_SOURCE@", volumeStep ? "5%", wireplumberPackage ? null }`
  Binds standard media and volume keys using `wpctl` and `playerctl`. Also aliased under `hyprland.keybind.useMediaFunctions`.

- `hyprland.keybinds.useToggleMonitorSetup { settings ? [] }`
  Generates a monitor-toggle helper script for each entry in `settings`, adds the scripts to `home.packages`, and binds each to its configured key (`"SUPER SHIFT, P"` by default).
  Each entry has the form:

```nix
{
  monitorName = "eDP-1";
  defaultSetup = { output = "eDP-1"; mode = "3456x2160@60"; position = "0x0"; scale = 1.6; };
  toggleSetup = { output = "eDP-1"; mode = "3456x2160@120"; position = "0x0"; scale = 1.6; };
  key = "SUPER SHIFT, P";
}
```

  `defaultSetup` and `toggleSetup` are `hl.monitor` attribute sets applied via `hyprctl eval`. The helper compares the monitor's current integer-rounded refresh rate against the `@<rate>` in `toggleSetup.mode`, switching to `defaultSetup` when already at the toggle rate and to `toggleSetup` otherwise.
  Assertion: both setups must specify an explicit `@<rate>` in `mode`, and their rounded refresh rates must differ.

#### `modules.desktop.hyprland.touchpad`

- `hyprland.touchpad.useDefaults {}`
  Applies the repository's default touchpad settings.

#### `modules.desktop.hyprland.touchpad.gestures`

- `hyprland.touchpad.gestures.useWorkspaces {}`
  Enables three-finger horizontal swipe gestures for switching workspaces.

#### `modules.desktop.hyprland.wallpaper`

- `hyprland.wallpaper.useHyprpaper { wallpaper ? null, monitors ? [], wallpapers ? [] }`
  Configures Hyprpaper using either a single `wallpaper` applied across `monitors` or a per-monitor `wallpapers` list (`{ monitor = "DP-3"; path = "/path/to/file"; }`).
  When `wallpapers` is non-empty, it takes precedence over `wallpaper` and `monitors`.
  Assertion: the provided arguments must resolve to at least one wallpaper assignment.

- `hyprland.wallpaper.useLinuxWallpaperEngine { wallpapers, fps ? 60 }`
  Starts Linux Wallpaper Engine from Hyprland's Lua `hyprland.start` event and installs a restart helper script. Uses SDL's dummy audio driver in silent mode so muted wallpapers do not occupy a PipeWire sink.
  `wallpapers` takes a non-empty list of `{ screen = "DP-3"; wallpaper = "2798192282"; }` entries.
  Assertion: `wallpapers` must not be empty.

#### `modules.desktop.hyprland.windowRules`

- `hyprland.windowRules.useDefaults {}`
  Initializes the Hyprland `window_rule` list as empty (currently adds no rules of its own).

- `hyprland.windowRules.useFixed { class, workspace }`
  Pins windows matching the regex `class` to `workspace`. The four `useFixed*` helpers below wrap this module with preset class patterns.

- `hyprland.windowRules.useFixedDiscord { workspace }`
  Pins Discord windows to `workspace`.

- `hyprland.windowRules.useFixedSpotify { workspace }`
  Pins Spotify windows to `workspace`.

- `hyprland.windowRules.useFixedMopiMopi { workspace }`
  Pins MopiMopi windows to `workspace`.

- `hyprland.windowRules.useFixedVesktop { workspace }`
  Pins Vesktop windows to `workspace`.

- `hyprland.windowRules.useHidden { initialClass, processArgv0, initialTitle ? "", xwayland ? true, workspace ? "hidden" }`
  Quarantines matching windows into an invisible special workspace (`special:<workspace>`) without terminating their process. A window matches only when its display backend (`xwayland`), `initialClass`, `initialTitle`, and `/proc/<pid>/cmdline` `argv[0]` (`processArgv0`) all match exactly; unreadable or missing `/proc` data leaves the window untouched. Set `xwayland = false` for native Wayland windows (including Wine's Wayland driver). `initialClass` and `processArgv0` must be non-empty strings, `initialTitle` may be empty, `xwayland` must be a boolean, and `workspace` (given without the `special:` prefix) may contain only letters, digits, underscores, or hyphens. Use a distinct `workspace` name per `useHidden` instance. Requires `useHyprland`'s `hyprLua` helper.
  Under the hood, a Lua `window.open_early` handler tags verified windows before initial focus or rendering, applying tag-scoped dynamic rules that strip focus, focus-on-activation, opacity, blur, shadows, decorations, and animations. A `window.open` handler then moves the window to `special:<workspace>` silently without relying on static rules that have already evaluated in Hyprland 0.57.
  On config reload, existing matching windows are reconciled immediately, and any tagged window moved out of its reserved workspace is returned to it. If the reserved special workspace is ever revealed (for example via a switcher), a deferred event handler closes it via Hyprland 0.57's Lua monitor API so the invisible overlay cannot intercept clicks on normal workspaces; other special workspaces are unaffected.
  Note: this hides windows visually within Hyprland, not from third-party task switchers, and is not a security boundary.

## `modules.programs`

### `modules.programs.gaming`

- `programs.gaming.useLsfgVk {}`
  Installs `lsfg-vk` and `lsfg-vk-ui`.

- `programs.gaming.useLutris {}`
  Installs Lutris.

- `programs.gaming.useMangoHud { enableSessionWide ? false, settings ? {}, settingsPerApplication ? {} }`
  Enables Home Manager's MangoHud module, writes `settings`, and injects MangoHud into Steam's FHS environment.

- `programs.gaming.useProtonplus {}`
  Installs ProtonPlus.

- `programs.gaming.useR2modman {}`
  Installs `r2modman`.

- `programs.gaming.useSteam { enableGamescope ? false, enableProtontricks ? false }`
  Enables Steam alongside optional Gamescope and Protontricks support. When `enableGamescope = true`, also enables `services.ananicy` (`ananicy-cpp`) with a single `nice = -20` rule for Gamescope and no default ruleset.

- `programs.gaming.useWine { isWayland ? false }`
  Installs either the Wayland-enabled Wine build (`wineWow64Packages.waylandFull`) or the full X11 build (`wineWow64Packages.full`).

#### `modules.programs.gaming.ffxiv`

- `programs.gaming.ffxiv.useCactbot {}`
  Installs Chromium webapp launchers for `Cactbot - Raidboss` and `Cactbot - Configuration`.

- `programs.gaming.ffxiv.useFFXIV { enableFileSecret ? false, enableDotNetIPv6 ? true }`
  Installs `xivlauncher-rb`, patching its desktop entry when requested to set `XL_SECRET_PROVIDER=file` and/or `DOTNET_SYSTEM_NET_DISABLEIPV6=1`.

- `programs.gaming.ffxiv.useMopiMopi {}`
  Installs a `mopimopi` launcher and desktop entry that opens the MopiMopi overlay in Chromium app mode.

- `programs.gaming.ffxiv.useXivMitmClientRoutes { gateway, interface, ranges ? null }`
  Wraps `xivmitm-nix.nixosModules.client` to route FFXIV client traffic through the specified `gateway` and network `interface`.

- `programs.gaming.ffxiv.useXivMitmGateway { listenPort ? 10514, incomingInterface ? null, outgoingInterface ? incomingInterface, clientCidr ? null, portRange ? "1024:65535", ranges ? null, manageDocker ? false, runContainer ? false, ffxivDx11Exe ? null, dataDir ? null, listenAddress ? null, measurePing ? null, webStatistics ? null, extraMitmArgs ? null }`
  Wraps `xivmitm-nix.nixosModules.server` to configure server-side sysctls and `iptables` routing for XivMitmLatencyMitigator. Non-null optional arguments are forwarded to the upstream module, while Docker container management remains disabled by default in favor of manual Compose deployments.

### `modules.programs.jetbrains`

- `programs.jetbrains.useIntellij { enableZshAlias ? false }`
  Installs IntelliJ IDEA and optionally defines an `idea()` Zsh function that launches the IDE in the background.

- `programs.jetbrains.usePycharm { enableZshAlias ? false }`
  Installs PyCharm (`pkgs.jetbrains.pycharm`) and optionally defines a `pycharm()` Zsh launcher function.

- `programs.jetbrains.useWebstorm { enableZshAlias ? false }`
  Installs WebStorm and optionally defines a `webstorm()` Zsh launcher function.

### `modules.programs.shell`

- `programs.shell.useShell {}`
  Adds Bash to `environment.shells` and sets `EDITOR=nano`.

- `programs.shell.useZsh {}`
  Enables Zsh system-wide and sets it as the primary user's login shell. Configures Home Manager Zsh with `oh-my-zsh`, autosuggestions, syntax highlighting, and a store-backed Powerlevel10k configuration, while disabling the redundant system-level `compinit` and prompt initialization.

### Other `modules.programs` exports

- `useAlsaUtils {}`
  Installs the ALSA command-line utilities (`alsa-utils`).

- `useAntigravity {}`
  Installs Google Antigravity (`default`, `google-antigravity-ide`, and `google-antigravity-cli`) from the `antigravity-nix` flake input via `environment.systemPackages`.

- `useAyugram {}`
  Installs AyuGram Desktop.

- `useBlueman {}`
  Enables the Blueman D-Bus service while suppressing its default XDG autostart entry.

- `useClaudeCode {}`
  Applies the `claude-code` overlay, installs Claude Code, and configures its Home Manager module with a runtime `npx` status-line wrapper pinned to a specific `@owloops/claude-powerline` version. Enables `mutableSettings` so `~/.claude/settings.json` remains writable at runtime with declared settings merged in on activation.

- `useClaudeDesktop { withFhs ? true, enableWayland ? false }`
  Applies the `claude-desktop` flake overlay (`aaddrick/claude-desktop-debian`, repackaged from Anthropic's official Linux `.deb`) and installs Claude Desktop. `withFhs = true` selects `claude-desktop-fhs` (bundling `node`, `uv`, `docker`, and common utilities for MCP servers), whereas `false` installs the plain `claude-desktop` package. `enableWayland = true` exports `CLAUDE_USE_WAYLAND=1` so the client runs natively under Wayland. Application state is stored under `~/.config/Claude` (covered by `/home` persistence).

- `useCodex {}`
  Installs the Codex CLI from the `codex-cli-nix` flake input.

- `useCodexAuth {}`
  Installs a NixOS-compatible wrapper for `codex-auth` `0.2.10` that patches the upstream Linux native binary, supplies Node.js 24 for API token refreshes, and preserves the active `PATH` so it can invoke the Codex CLI.

- `useCodexDesktop { quitOnClose ? false, enableComputerUse ? false }`
  Enables the Codex Desktop Linux Home Manager module from the `codex-desktop` flake input.
  - `quitOnClose = true`: Patches the application so closing the last window exits Codex Desktop instead of hiding it to the system tray.
  - `enableComputerUse = true`: Bundles the local Linux Computer Use backend (applied prior to the optional `quitOnClose` patch), enables AT-SPI accessibility and the `ydotool` daemon with `uinput` support, and grants the primary user access to the daemon socket and `/dev/uinput` for pointer control. After rebuilding and logging back in, enable **Settings → Computer use → Any App** inside Codex Desktop. Does not enable remote control.

- `useCommonTools {}`
  Installs the repository's standard CLI utility set.

- `useChrome {}`
  Installs Google Chrome.

- `useChromium { commandLineArgs ? [], language ? "ko-KR", languageEnvironment ? null }`
  Enables `programs.chromium` and installs a localized Chromium wrapper. Defaults to exporting `LANGUAGE=ko_KR:ko` and passing `--lang=ko-KR`; setting `language = null` disables both, while `languageEnvironment` can override the `LANGUAGE` environment variable directly.

- `useDirenv {}`
  Enables Direnv in Home Manager with Bash, Zsh, and `nix-direnv` integration.

- `useDiscord {}`
  Installs the stock Discord package (an XWayland/fcitx desktop-entry override for IME behavior is kept commented out in the module).

- `useDolphin { withSilentKdeDeps ? false }`
  Installs KDE Dolphin. When `withSilentKdeDeps = true`, wraps Dolphin with the KService, KDE CLI, and KIO dependencies required for working "Open With" associations outside Plasma while silencing cache-rebuild noise, and rewrites Dolphin's D-Bus (`org.freedesktop.FileManager1`) and systemd user service files so external activations (such as a browser's "Show in Folder") also use the wrapped binary.

- `useEquibop { package ? null }`
  Installs Equibop and registers it as the default handler for `x-scheme-handler/discord`.

- `useFastfetch { beforeModules ? [], afterModules ? [] }`
  Installs Fastfetch and generates its JSON configuration with `beforeModules` and `afterModules` prepended and appended around the repository's default module list.

- `useFirefox { enableWidevine ? false }`
  Enables Firefox. When `enableWidevine = true`, applies the `aarch64-widevine` overlay from `specialArgs` and sets `MOZ_GMP_PATH` to `pkgs.widevine-cdm-lacros` (hosts that leave `enableWidevine = false` do not need to pass the `aarch64-widevine` input).

- `useForgeCode { enableZshIntegration ? false }`
  Installs ForgeCode (`modules/programs/forge-code/pkg.nix`, wrapping the upstream prebuilt release binary), installs companion tools, exports `FORGE_BIN`, and optionally enables Zsh integration. On Home Manager activation, cleans up remnants from upstream's standalone installer (`~/.bashrc` snippets and any non-symlink `~/.local/bin/forge` binary).

- `useGit { name, email }`
  Enables Git and Git LFS in Home Manager, configures the user's commit identity and default branch, and enables the GitHub CLI (`gh`) as the Git credential helper.

- `useGptOauthServer { host ? "127.0.0.1", port ? 10531, version ? "1.0.1", authFile ? null, models ? null, codexVersion ? null, baseUrl ? null, oauthClientId ? null, oauthTokenUrl ? null, extraArgs ? [] }`
  Installs a `gpt-server` wrapper that runs `npx --yes openai-oauth@${version}` with the configured options and forwards any runtime arguments. Binds to loopback by default; pass `host = "0.0.0.0"` to expose it on the network.
  Assertions: `host` must be a non-empty string, `port` an integer from `1` to `65535`, `models` either `null` or a list of strings, and `extraArgs` a list of strings.

- `useHaruna {}`
  Installs Haruna.

- `useHyprshot {}`
  Installs Hyprshot.

- `useK3b {}`
  Installs K3b.

- `useKcalc { enableWindowsAlias ? false }`
  Installs KCalc and optionally adds a `calc` desktop entry alias.

- `useKitty {}`
  Installs Kitty and manages `kitty.conf` via Home Manager.

- `useKolourpaint { enableWindowsAlias ? false }`
  Installs KolourPaint and optionally adds a `pbrush` desktop entry alias.

- `useLact { enableDaemon ? true, persistPath ? null }`
  Installs LACT. When `enableDaemon = true`, enables `services.lact` (`lactd`) and persists `/etc/lact` to retain GPU fan curves and tuning profiles.

- `useLibreOffice {}`
  Installs a wrapped `libreoffice-qt` package that forces the Qt6 VCL backend and strips global Qt style overrides.

- `useMoonlight {}`
  Installs Moonlight Qt.

- `useNixIndex {}`
  Enables `nix-index` in Home Manager with Bash and Zsh integration.

- `useNmApplet {}`
  Installs `networkmanagerapplet`.

- `useObsidian {}`
  Installs Obsidian.

- `useObsStudio { enableVirtualCamera ? false, enableAmdVaapi ? true, extraPlugins ? [] }`
  Enables OBS Studio with the repository's default plugin bundle plus optional virtual camera, AMD VAAPI, and `extraPlugins` support.

- `usePeaZip {}`
  Installs PeaZip.

- `usePwvucontrol {}`
  Installs `pwvucontrol`.

- `useShotcut {}`
  Installs Shotcut.

- `useSshClient { settings ? {}, enableDefaultConfig ? false }`
  Enables the Home Manager OpenSSH client and writes host blocks to `programs.ssh.settings`. When `enableDefaultConfig = false`, explicitly populates the legacy Home Manager `Host *` defaults; providing a `"*"` key in `settings` replaces that entire default block rather than merging into it.

- `useSpotify {}`
  Installs the official Spotify client on `x86_64-linux`, or `spotify-qt` paired with `librespot` on `aarch64-linux` (updating `~/.config/spotify-qt.json` in place when present and valid JSON).

- `useTauon {}`
  Installs Tauon Music Box.

- `useThunderbird { package ? null }`
  Enables Thunderbird via the NixOS `programs.thunderbird` module.

- `useVesktop {}`
  Installs Vesktop with Wayland IME flags baked into its desktop entry.

- `useVscode {}`
  Installs VS Code.

- `useVim { enableGui ? true }`
  Configures Neovim via Home Manager and optionally installs the Neovide GUI with a Nerd Font, wired to launch the Home Manager Neovim build (`neovide` for the GUI, `nvim` in a terminal). Leaves `$EDITOR`, VS Code, and MIME associations unchanged; runtime state lives under standard XDG directories covered by `/home` persistence.
  All plugins, Tree-sitter parsers, language servers, and formatters are provisioned declaratively through Nix rather than downloaded at runtime via Lazy or Mason. Built-in features include a file tree, project-wide search, completion, Git gutter and LazyGit integration, GitHub PR/issue management via Octo (reusing existing `gh` authentication), and manual formatting. Language servers cover JavaScript/TypeScript, Python, Java (`jdtls`, with isolated per-project writable caches), Nix, Lua, Bash, JSON, HTML/CSS, C/C++, Rust, and Go; editor tooling is appended to `PATH` so project environments can still supply their own runtimes.
  Provides an IDE-like layout with clickable `File`/`Edit`/`View`/`Go`/`Code`/`Git`/`Help` menus, buffer tabs with dirty indicators, a persistent left sidebar (`Files`/`Git`/`Open`, toggled via `Alt+1`/`2`/`3`), floating path/choice dialogs, a bottom status bar and terminal, and a searchable command palette (`Ctrl+Shift+P`, `F4`, or via the `Help` menu; `rflxn-desktop` binds screen power to `Super+Ctrl+P` to avoid colliding with `Ctrl+Shift+P`). Closing a file preserves the sidebar layout and prompts to save, discard, or cancel. `Space` is the leader key, and `F1` opens the built-in quick-start guide.
  In Neovide, buffers start in Insert mode with GUI-style keybindings (`Shift`+arrows and mouse drag for selection, `Ctrl+A`/`C`/`X`/`V`/`Z`/`Y` for select-all/clipboard/undo/redo, and `Ctrl+N`/`O`/`S`/`W`, `Ctrl+Tab`, `Ctrl+F`/`H` for file, tab, and search actions; `Esc` still enters Normal mode). Terminal `nvim` retains standard modal editing defaults.

- `useWaylandUtils {}`
  Installs `wl-clipboard` and `wayland-utils`.

## `modules.services`

### `modules.services.nginx`

- `services.nginx.useNginX { upstreams ? {} }`
  Enables Nginx with the repository's recommended gzip, optimization, and proxy defaults.

#### `modules.services.nginx.vhosts`

- `services.nginx.vhosts.useDeluge { port ? 8112 }`
  Proxies the Deluge Web UI under `/torrent`.

- `services.nginx.vhosts.useSyncthing { port ? 8384 }`
  Proxies the Syncthing Web GUI under `/syncthing` with Syncthing-specific proxy headers.

### `modules.services.pipewire`

- `services.pipewire.usePipewire {}`
  Enables PipeWire with ALSA, PulseAudio, and JACK support (enabling 32-bit ALSA support on `x86_64` only).

- `services.pipewire.useDenoisedMic {}`
  Registers an `rnnoise` filter-chain virtual source named `Noise Canceling Source`.

- `services.pipewire.useLowLatency { quantum ? 64, defaultRate ? 48000, allowedRates ? [ 44100 48000 88200 96000 176400 192000 352800 384000 705600 768000 ], resampleQuality ? 10 }`
  Pins the PipeWire graph to a fixed low-latency buffer size by setting `default.clock.quantum`, `min-quantum`, and `max-quantum` to `quantum` (expressed in frames at `defaultRate` and scaled proportionally at other sample rates). Pinning all three prevents a single client requesting a large buffer from raising latency for the rest of the graph.
  Also lowers the PulseAudio compatibility floor (`pulse.min.req`, `pulse.min.frag`, `pulse.min.quantum`) from the 256-frame default to `quantum` so PulseAudio clients (such as Wine/Proton and SDL titles) can request small buffers.
  `allowedRates` permits dynamic sample-rate switching when the output device is idle; if a persistent stream (such as an effects processor or replay recorder) holds the device open, the graph remains locked to its current rate and resamples other streams at `resampleQuality` (`0`–`14`, compared to PipeWire's default of `4`, applied across native streams, PulseAudio streams, and ALSA nodes).
  Assertions: `quantum` and `defaultRate` must be positive integers, `allowedRates` must be non-empty and contain `defaultRate`, and `resampleQuality` must be between `0` and `14`.

- `services.pipewire.useAudioModes { hifiQuantum ? 1024, hifiMinQuantum ? 256, hifiMaxQuantum ? 2048, hifiStopUserServices ? [] }`
  Installs the `audio-mode` CLI (`audio-mode [gaming|hifi|toggle|status]`) and desktop entries (`Audio Mode: Gaming` and `Audio Mode: Hi-Fi`), sending a desktop notification whenever the active mode changes.
  - **Gaming mode (default on login):** Uses the baseline PipeWire clock settings configured on the daemon (e.g., from `useLowLatency`) and keeps all background audio user services running.
  - **Hi-Fi mode:** Stops the user units listed in `hifiStopUserServices` (which should include any service holding a persistent audio stream, such as EasyEffects or GPU Screen Recorder) and relaxes the PipeWire clock to `hifiMinQuantum`–`hifiMaxQuantum` (with default `hifiQuantum`). With no persistent streams keeping the sink active, the output device goes idle between tracks and switches natively to each stream's sample rate (for any rate in `allowedRates`) without resampling.
  Switching back to Gaming mode restores the baseline clock settings and restarts the stopped user services. Mode state is stored in `$XDG_RUNTIME_DIR` per login session; while Hi-Fi mode is active, a systemd drop-in condition prevents the stopped services from auto-restarting, and the `audio-mode` user unit reapplies the Hi-Fi clock settings if PipeWire restarts.
  Assertions: PipeWire must be enabled, `hifiMinQuantum <= hifiQuantum <= hifiMaxQuantum` must all be positive integers, and every entry in `hifiStopUserServices` must end in `.service`.

### Other `modules.services` exports

- `useDocker { isBtrfs ? false, isRootless ? false, containersAsService ? {}, persistPath ? null }`
  Enables the system Docker daemon on boot, optionally selects the `btrfs` storage driver, forwards `containersAsService` to `virtualisation.oci-containers.containers` (using the Docker backend), and persists `/var/lib/docker`.
  When `isRootless = false`, adds the primary user to the `docker` group. When `isRootless = true`, enables rootless Docker alongside the system daemon and exports `DOCKER_HOST` for the user (system daemon state remains in `/var/lib/docker`, while rootless state lives under the user's home directory).

- `useDeluge { authFile ? null, downloadDir ? null, webAuthFile ? null, webHost ? "0.0.0.0", webPort ? 8112, allowRemote ? false, persistPath ? null }`
  Enables `deluged` and `delugeweb` in non-declarative mode under the primary user and group, leaves the firewall closed, and persists `/var/lib/deluge`. `downloadDir = null` defaults to `/home/${username}/data/torrents`.
  On every start, `deluged` updates `core.conf` with `allow_remote = allowRemote` and the configured download directory, resetting any manual changes to those keys (`allowRemote = false` binds the daemon RPC port to loopback, which suffices for the local Web UI; set `true` for remote thin clients). If `authFile` is provided, it is copied to `/var/lib/deluge/.config/deluge/auth` on start.
  If `webAuthFile` (a JSON file containing `pwd_salt` and `pwd_sha1`) is provided, `delugeweb` rewrites `web.conf` on every start with `webHost`, `webPort`, and the password hashes; without `webAuthFile`, only `webPort` is configured.
  Assertion: setting a non-default `webHost` requires `webAuthFile`, as the listen address is written as part of the `webAuthFile` block.

- `useEasyEffects { preset ? "", extraPresets ? {} }`
  Enables the Home Manager EasyEffects user service and required system `dconf` support. State and presets live under the user's XDG directories (covered by `/home` persistence).
  Assertion: PipeWire must be enabled.

- `useFlatpak { persistPath ? null }`
  Enables Flatpak and persists `/var/lib/flatpak`.

- `useGpuScreenRecorder { window ? "screen", framerate ? 60, replaySeconds ? 300, replayStorage ? "ram", restartReplayOnSave ? false, bitrateMode ? "cbr", bitrate ? 40000, quality ? "high", container ? "mp4", audioSource ? "default_output", makeDateFolders ? false, postSaveScript ? null, outputDir ? null }`
  Enables the NixOS GPU Screen Recorder capability wrapper, configures a replay-buffer systemd user service, and installs the `gsr-save-replay` CLI helper and desktop entry (which signals only the service's main process). `outputDir = null` defaults to `/home/${username}/Videos/replays`. `bitrate` sets the target kbps in `cbr` mode, while `quality` applies to the other bitrate modes.
  Assertions: `framerate` and `bitrate` must be positive integers; `replaySeconds` must be between `2` and `86400`; `replayStorage` must be `"ram"` or `"disk"`; `bitrateMode` must be `"auto"`, `"qp"`, `"vbr"`, or `"cbr"`; and `quality` must be `"medium"`, `"high"`, `"very_high"`, or `"ultra"` whenever `bitrateMode != "cbr"`.

- `useHomeManager { stateVersion ? "25.11", backupCommand ? null }`
  Imports the Home Manager NixOS module, enables `useGlobalPkgs`, `useUserPackages`, and `programs.home-manager`, and configures file-backup handling.

- `useJetbrainsRemote { ides ? [] }`
  Enables the Home Manager JetBrains Remote module with the specified `ides` list.

- `useKeyd { settings ? {} }`
  Enables `keyd` and assigns `services.keyd.keyboards = settings`.

- `useLibinput {}`
  Enables `libinput`.

- `useLinuxWallpaperengine { wallpapers, fps ? 60 }`
  Configures a systemd user service for Linux Wallpaper Engine and installs a `restart-wallpaper` helper script (`wallpapers` takes entries of the form `{ screen = "DP-3"; wallpaper = "2798192282"; }`).
  Note: this is the standalone systemd-service variant, whereas `modules.desktop.hyprland.wallpaper.useLinuxWallpaperEngine` launches from Hyprland's Lua `hyprland.start` hook.

- `useNginX { upstreams ? {} }`
  Alias for `services.nginx.useNginX`.

- `useRemovableStorageAutoMount { mountOnMedia ? false, notify ? true, tray ? "auto" }`
  Enables `udisks2` and the Home Manager `udiskie` user service for automatic removable-media mounting. Mounts under `/run/media/$USER` by default, or under `/media` when `mountOnMedia = true`.

- `useRtkit {}`
  Enables `rtkit` (RealtimeKit).

- `useSamba { directories ? {}, persistPath ? null }`
  Enables Samba, exports one share per entry in `directories` (e.g., `{ data = "/home/rflxn/data"; }`) with ownership forced to the primary user and group, and persists `/var/lib/samba`.
  Assertion: `directories` must not be empty.

- `useSpotifySoloist { keyFile, deviceName ? null, initialVolume ? null, pipewireDevice ? null, cacheSize ? null, websocketAddress ? null, verbose ? false, extraArgs ? [] }`
  Runs Spotify Soloist (headless Spotify Connect receiver) as a `spotify-soloist` systemd user service bound to `graphical-session.target` so audio routes through the user's PipeWire session (bypassing the upstream `services.soloist` NixOS module, which requires system-wide PipeWire). Also installs the `soloist` CLI (`soloist ctl`).
  Reads the Soloist developer API key from `keyFile` at service startup (must be readable by the primary user) and defaults `deviceName` to `networking.hostName`. Runtime state and cache live under `~/.local/share/soloist` and `~/.cache/soloist` (covered by `/home` persistence).
  Assertions: `keyFile` must be an absolute path string (Nix path literals are rejected), the resolved device name must be a non-empty string, `initialVolume` must be `0`–`100`, `pipewireDevice` must be `null` or a non-empty string, `cacheSize` must be `0` or `>= 100`, `websocketAddress` must match `ADDR:PORT`, `verbose` must be a boolean, `extraArgs` must be a list of strings, and PipeWire must be enabled.

- `useSsh { persistPath ? null, allowPasswordLogin ? false }`
  Enables OpenSSH, disables root login, and persists host keys. `allowPasswordLogin` controls both `PasswordAuthentication` and `KbdInteractiveAuthentication` (`false` enforces key-only authentication).

- `useSyncthing { devices ? {}, folders ? {}, serviceLevel ? "user", webHost ? "127.0.0.1", webPort ? 8384, persistPath ? null }`
  Enables Syncthing either as a Home Manager user service (`serviceLevel = "user"`) or as a NixOS system service running under the primary user (`serviceLevel = "system"`, which creates and persists `/var/lib/syncthing`; any other `serviceLevel` fails evaluation).
  The Web GUI binds to loopback by default; configure GUI credentials inside Syncthing before exposing `webHost`, as this module does not declare GUI authentication.
  `devices` and `folders` are forwarded to Syncthing's declarative settings, where `folders` entries have the form:

```nix
{
  development = {
    id = "development";
    path = "/home/rflxn/development";
    devices = [ "rflxn-server" ];
  };
}
```

  Note: `persistPath` applies only when `serviceLevel = "system"`.

- `useTailscale { persistPath ? null, enableSystemTray ? false, openFirewall ? false }`
  Enables Tailscale, optionally opens its UDP port in the firewall, optionally starts a user system-tray service (`--operator=${username}`), and persists `/var/lib/tailscale`.

- `useVscodeServer {}`
  Imports `nixos-vscode-server` and enables the VS Code Server service.

## Internal Helpers and Non-Exported Files

The following files are internal implementation details and are not exported under `modules`:

- `modules/desktop/default-apps/utils.nix`
  Provides the `mkMimeDefaults` and `mkMimeApps` helpers.

- `modules/programs/forge-code/pkg.nix`
  Package derivation used by `useForgeCode`.

- `modules/services/nginx/vhosts/port-redirect-helper.nix`
  Shared reverse-proxy helper used by the Deluge and Syncthing vhost modules.

- `modules/desktop/qt/theme/matcha-kdeglobals.nix`
  `kdeglobals` color-scheme data written by `qt.theme.useMatcha`.

- `modules/programs/gaming/ffxiv/chromium-webapp.nix`
  Helper that builds a Chromium `--app` launcher with an isolated profile directory and desktop entry (used by `useCactbot` and `useMopiMopi`).

- `modules/desktop/hyprland/lua-helpers.nix`
  Defines the `hyprLua` helper set (`bind`, `bindWith`, `execBind`, `execBindWith`, `onStart`, `toLua`, `lua`, `keyFromHyprlang`), imported by `hyprland.useHyprland` and exposed via `_module.args.hyprLua`.

- `modules/services/syncthing/system-service.nix` and `modules/services/syncthing/user-service.nix`
  Internal branches selected by `useSyncthing` based on `serviceLevel`.

Non-Nix assets read by their neighboring modules are also internal: `dank-linux/battery-charge-limit.py`, `hyprshell/styles.css`, and `window-rules/hidden.lua` under `modules/desktop/hyprland`; and `claude-code/claude-powerline.json`, `kitty/kitty.conf`, `shell/zsh/p10k.zsh`, and `vim/{init,layout,gui}.lua` under `modules/programs`.

## Current API Constraints

- `services.useSyncthing.persistPath` only takes effect when `serviceLevel = "system"`.
- `services.useNginX` and `services.nginx.useNginX` alias the same module.
- `hyprland.keybind` and `hyprland.keybinds` alias the same namespace.
- `hyprland.useHyprlock`, `hyprland.useHyprshell`, all `hyprland.keybinds.*` modules, `hyprland.wallpaper.useLinuxWallpaperEngine`, and `hyprland.windowRules.useHidden` require `hyprland.useHyprland` in the same host.
- `hyprland.keybinds.useDankLinuxLauncher` with `package = null` requires `hyprland.useDankLinux`.
- `services.useDeluge.webHost` only takes effect when `webAuthFile` is set.
- `hardware.useAmdGpu` does not enable `hardware.graphics`; import `hardware.useGraphics` alongside it.
- `qt.theme.useRosePine`'s `kvantum*` arguments only take effect when `useOverlay = true`.
