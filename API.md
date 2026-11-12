# Module API

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
- Persistence-aware modules persist into `persistPath` when it is passed and into the `defaultPersistPath` special arg otherwise. Hosts must provide `defaultPersistPath` (currently `"/persist"`); second-stage module arguments cannot have working defaults, so a missing special arg is an evaluation error as soon as it is used.
- Many modules assume `username` is provided through `specialArgs`.
- Some modules require flake inputs to be passed into host `specialArgs`.
- Hyprland modules that take the `hyprLua` helper require `modules.desktop.hyprland.useHyprland` in the same host, which injects it through `_module.args.hyprLua`. This covers every `hyprland.keybinds.*` export, `hyprland.useHyprlock`, `hyprland.useHyprshell`, `hyprland.wallpaper.useLinuxWallpaperEngine`, and `hyprland.windowRules.useHidden`.

Required input-backed modules:

| Module | Required special arg |
| --- | --- |
| `modules.system.boot.useLanzaboote` | `lanzaboote` |
| `modules.system.boot.grub.theme.useDistroTheme` | `distro-grub-themes` |
| `modules.system.useImpermanence` | `impermanence` |
| `modules.desktop.hyprland.useDankLinux` | `dank-material-shell` |
| `modules.desktop.hyprland.useHyprland` | optional `hyprland` input (read from `specialArgs`), otherwise falls back to `pkgs.hyprland` |
| `modules.desktop.hyprland.useHyprshell` | optional `hyprshell` input, otherwise falls back to `pkgs.hyprshell` |
| `modules.programs.useClaudeCode` | `claude-code` |
| `modules.programs.useClaudeDesktop` | `claude-desktop` |
| `modules.programs.useAntigravity` | `antigravity-nix` |
| `modules.programs.useCodex` | `codex-cli-nix` |
| `modules.programs.useCodexDesktop` | `codex-desktop` |
| `modules.programs.useFirefox { enableWidevine = true; }` | `aarch64-widevine` (only looked up when `enableWidevine = true`) |
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
  Enables GRUB for UEFI systems with `device = "nodev"`, disables OS prober by default, and optionally configures timeout, retained configurations, default entry, EFI graphics mode/payload, and timeout style.

- `boot.grub.theme.useDistroTheme { name ? "nixos" }`
  Applies the `<name>-grub-theme` package from `distro-grub-themes` to GRUB and sets `boot.loader.grub.splashImage` to that theme's `splash_image.jpg`.
  Assertion: `distro-grub-themes` must provide `<name>-grub-theme` for the host system.

- `boot.useLanzaboote { persistPath ? null }`
  Enables Lanzaboote, disables direct `systemd-boot`, installs `sbctl`, and persists `/var/lib/sbctl`.
  Not currently imported by any host; Secure Boot is no longer used.

- `boot.usePlymouth { theme ? "breeze", enableQuietBoot ? true }`
  Enables Plymouth. With `enableQuietBoot`, sets `boot.consoleLogLevel = 0` and the `quiet`, `udev.log_level=0`, and `systemd.show_status=false` kernel parameters.

- `boot.useSystemdBoot { consoleMode ? null, configurationLimit ? 15 }`
  Enables `boot.loader.systemd-boot` and optionally sets console mode and configuration retention.

### `modules.system.nix`

- `nix.useCache {}`
  Adds the `claude-code.cachix.org` binary cache and its public key. `cache.nixos.org` comes from the NixOS default.

- `nix.useExperimentalFeatures {}`
  Enables `nix-command` and `flakes`.

- `nix.useGc { dates, options ? "--delete-older-than 30d" }`
  Enables automatic GC with the provided `dates` value. `options` is passed to `nix-collect-garbage`; the default also deletes profile generations older than 30 days, and `""` only removes unrooted store paths.

- `nix.useOptimise { dates }`
  Enables automatic Nix store optimisation with the provided `dates` value.

- `nix.useUnfreePackage {}`
  Sets `nixpkgs.config.allowUnfree = true`.

### Other `modules.system` exports

- `useCjkFonts {}`
  Installs and configures the repo's default Latin, Korean, and Japanese fonts, including custom `fontconfig` language preferences.

- `useFcitx5 {}`
  Enables `fcitx5` with GTK, Hangul, and Mozc addons.

- `useFirewall { trustedInterfaces ? [] }`
  Enables the NixOS stateful firewall and unconditionally accepts incoming traffic from the specified interfaces.

- `useImpermanence { rootUuid, persistPath ? null, directories ? [], files ? [], enableWipeRoot ? true }`
  Enables impermanence, optionally resets `@root` from `@root-blank` during initrd, writes wipe-root diagnostics to `/persist/log/wipe-root.log` when `@persist` exists, persists `/home`, `/var/log`, `/var/lib/nixos`, `/var/lib/systemd/coredump`, `/var/lib/systemd/timers`, `/etc/machine-id`, and any extra directories/files provided.
  The previous `@root` is not deleted on reset: it is moved to `old_roots/<timestamp>` on the Btrfs top level and removed once it is older than 30 days. If `@root-blank` is missing, the existing `@root` is left in place.
  The diagnostics log is written to the `@persist` subvolume of the root filesystem (`rootUuid`), regardless of `persistPath`.
  `/var/lib/systemd/timers` keeps the last-run stamps of `Persistent=true` timers such as `nix.gc` and `nix.optimise`, so runs missed while the machine was off are caught up. The wipe is ordered after `systemd-hibernate-resume.service`, so a hibernated system resumes instead of having its root replaced.

- `useMe { hashedPassword ? null, hashedPasswordFile ? null, rootHashedPassword ? null, rootHashedPasswordFile ? null, extraGroups ? [] }`
  Creates the main user from `username`, disables mutable users, adds `wheel`, accepts either an inline hash or a password-hash file, and can optionally set the root password for emergency access.

- `useNetworkManager { useWifi ? false, persistPath ? null }`
  Enables NetworkManager with `dns = "none"`, adds the user to `networkmanager`, optionally enables `iwd`-backed Wi-Fi, and persists NetworkManager state.
  Because NetworkManager does not manage `resolv.conf` here, the host must provide DNS itself (for example `networking.nameservers`).
  With `useWifi = true`, Wi-Fi power saving is disabled and `/var/lib/iwd` is persisted alongside `/var/lib/NetworkManager` and `/etc/NetworkManager/system-connections`. NetworkManager keeps doing address and route configuration; `iwd` only handles the Wi-Fi association.

- `useNtSync {}`
  Loads the `ntsync` kernel module at boot (`boot.kernelModules`) for Wine/Proton NT synchronization primitives.

- `useZram { memoryPercent ? 25, priority ? 10 }`
  Enables zram swap with configurable memory percentage and priority.

## `modules.hardware`

- `useAmdGpu { enableOverdrive ? false }`
  Loads `amdgpu` in the initrd (`hardware.amdgpu.initrd.enable`), sets the X11 video driver to `amdgpu`, and optionally enables AMD overdrive. It does not enable `hardware.graphics`; import `useGraphics` alongside it.

- `useBluetooth { persistPath ? null }`
  Enables Bluetooth with `Experimental`, `FastConnectable`, and power-on-boot behavior, enables `upower`, and persists `/var/lib/bluetooth`.

- `useGraphics { enable32Bit ? null }`
  Enables `hardware.graphics`. `enable32Bit = null` enables 32-bit support on `x86_64` only; pass a boolean to force it.

- `useOpenrazer {}`
  Enables OpenRazer and grants access to the repo user.

## `modules.desktop`

### Top-level exports

- `useGreetd { enableRegreet ? false, regreetCompositor ? "hyprland", regreetPrimaryMonitor ? null, enableAutoLogin ? false, autoLoginSession ? "uwsm-hyprland", enableSilentSession ? enableAutoLogin }`
  Enables `greetd` for either Regreet or autologin. When both are enabled, autologin wins and Regreet never runs; `regreetCompositor` and `regreetPrimaryMonitor` then have no effect on the session.
  Autologin shows no greeter on purpose: the desktop shell's own lock screen (for example DMS with `lockAtStartup`) is expected to act as the login prompt. The autologin command is both greetd's `initial_session` and its `default_session`, so logging out logs straight back in.
  The first login after boot (`initial_session`) is a regular logind user session and can be locked through logind (`loginctl lock-session`, lid switch, shell lock integration). A re-login after logout goes through `default_session`, which greetd registers with the logind class `greeter`; that session cannot be locked through logind until the next boot.
  `autoLoginSession` accepts `"uwsm-hyprland"`, `"hyprland"`, or any other string, which is used as the raw session command.
  `regreetCompositor` accepts `"hyprland"`, `"cage"`, or any other string, which is used as the raw greeter command. The `"hyprland"` greeter runs `Hyprland -c /etc/greetd/hyprland.lua`, so Hyprland must be installed by another module.
  The Hyprland Regreet compositor configuration is generated as Lua.
  `enableSilentSession` applies to the built-in `"uwsm-hyprland"` and `"hyprland"` sessions: it clears the text console and redirects the session command output to the journal through `systemd-cat`. A custom `autoLoginSession` command and the Regreet command are not wrapped.
  `regreetPrimaryMonitor` should look like `{ name = "DP-3"; res = "1920x1080@200"; }`. It only applies to the `"hyprland"` Regreet compositor, and every other output is disabled while the greeter is shown.
  Assertion: at least one of `enableRegreet` or `enableAutoLogin` must be true.

### `modules.desktop.xdgPortal`

- `xdgPortal.useXdgPortal {}`
  Enables `xdg-desktop-portal`. It adds no backend, and NixOS asserts that `xdg.portal.extraPortals` is non-empty, so pair it with a backend module such as `useHyprlandPortal`.
  Unlike the other exports, its second stage is a plain attribute set rather than a `{ ... }:` function; it is still a valid NixOS module.

- `xdgPortal.useHyprlandPortal { useQtTheme ? false, enableGtkFallback ? true }`
  Configures Hyprland as the portal backend with GTK fallback (`default = [ "hyprland" "gtk" ]`).
  The Hyprland and GTK portal packages are only added by this module when `programs.hyprland.enable` is false; otherwise the NixOS Hyprland module already installs both.
  When `useQtTheme` is true, KDE's portal is installed and the file chooser portal is routed to KDE so Qt/Kvantum themed dialogs can be used.

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
  Sets PeaZip's `peazip-extract.desktop` entry as default for a large built-in set of archive/package MIME types.

- `defaultApps.useVscode { mimeTypes ? [...] }`
  Sets VS Code as default for the given text/code/config MIME types.

### `modules.desktop.gtk.theme`

- `gtk.theme.useMatcha { color ? "dark", variant ? "azul", windowOpacity ? 0.85 }`
  Configures Matcha GTK theme and optional transparency CSS.
  Allowed colors: `standard`, `light`, `dark`.
  Allowed variants: `aliz`, `azul`, `pueril`, `sea`.
  Assertion: `windowOpacity` must be between 0.0 and 1.0. The transparency CSS is only emitted below 1.0.

- `gtk.theme.usePapirusIcon { theme ? "Papirus-Dark" }`
  Configures Papirus icons in Home Manager GTK settings.
  Allowed values: `Papirus`, `Papirus-Dark`, `Papirus-Light`.

### `modules.desktop.qt`

- `qt.useDolphinQtTheme { colorScheme ? "*" }`
  Sets Dolphin's Qt/KDE color scheme through Home Manager. The wildcard default lets the active Qt theme supply the color scheme.

#### `modules.desktop.qt.theme`

- `qt.theme.useMatcha { color ? "dark", kvantumTranslucentWindows ? true, kvantumBlurring ? true, kvantumPopupBlurring ? true, kvantumReduceWindowOpacity ? 12 }`
  Packages `vinceliuice/Matcha-kde`, installs `qt6ct` and the Qt6 Kvantum style plugin, and configures Qt6 to use the Matcha Kvantum theme. Qt5 is not configured.
  The Kvantum theme is always the `sea` variant (`Matcha-sea` or `Matcha-sea-dark`); there is no `variant` argument.
  Sets `QT_QPA_PLATFORMTHEME=qt6ct` and `QT_STYLE_OVERRIDE=kvantum` at the system, Home Manager session, and systemd user levels, and writes the matching color scheme into `kdeglobals`. The values are plain definitions, so another module setting the same variables differently (for example `hyprland.useDarkMode` with its default `qtUseGtkPlatformTheme = true`) is an evaluation conflict rather than a silent override.
  Allowed colors: `light`, `dark` (`standard` is not accepted here, unlike `gtk.theme.useMatcha`). An invalid color fails evaluation with that message.
  Assertion: `kvantumReduceWindowOpacity` must be between 0 and 100.

- `qt.theme.usePapirusIcon { theme ? "Papirus-Dark" }`
  Installs Papirus icons and configures Qt5/Qt6 icon themes through `qt5ct` and `qt6ct`.
  Allowed values: `Papirus`, `Papirus-Dark`, `Papirus-Light`.

- `qt.theme.useRosePine { variant ? "main", accent ? "rose", useOverlay ? true, kvantumTranslucentWindows ? true, kvantumBlurring ? true, kvantumPopupBlurring ? true, kvantumReduceWindowOpacity ? 12 }`
  Installs and configures the Rose Pine Kvantum theme, optionally via a local overlay that rewrites `.kvconfig` files.
  Allowed variants: `main`, `moon`, `dawn`.
  Allowed accents: `rose`, `pine`, `foam`, `gold`, `iris`, `love`.
  The four `kvantum*` arguments only take effect through the overlay; with `useOverlay = false` they are ignored. The overlay replaces `pkgs.rose-pine-kvantum` for the whole system.
  Assertion: `kvantumReduceWindowOpacity` must be between 0 and 100. An invalid `variant` fails evaluation directly.

### `modules.desktop.logind`

- `logind.useLogind {}`
  Sets the power key to suspend and the lid switch to lock (on battery, on external power, and docked). Closing the lid does not suspend.

### `modules.desktop.hyprland`

- `hyprland.appearance { gapSize ? 5, borderSize ? 2, rounding ? 5, activeBorderColor ? "rgb(89b4fa)", inactiveBorderColor ? "rgb(585b70)", enableAnimations ? true, enableBlur ? true, activeOpacity ? 0.94, inactiveOpacity ? 0.86, fullscreenOpacity ? 1.0, blurSize ? 8, blurPasses ? 2 }`
  Applies the repo's default Hyprland window decoration, animation, dwindle, and scrolling settings.

- `hyprland.useDankLinux { batteryChargeLimit ? null, lockScreenPasswordField ? null, package ? null, session ? {}, settings ? {}, systemdTarget ? null, theme ? null }`
  Enables DankMaterialShell through Home Manager and declaratively manages the supplied DMS settings.
  The `dms` user service always runs with `DMS_DISABLE_POLKIT=1`, so DMS does not act as the polkit agent; use `hyprland.useHyprpolkit` for that.
  `batteryChargeLimit` accepts an integer from 50 to 100. It sets DMS's `settings.batteryChargeLimit` and enables the `dms-battery-charge-limit` system oneshot, which applies the same limit at boot and when the configured value changes during `nixos-rebuild switch`. The helper discovers batteries by sysfs type (which covers `macsmc-battery`), uses `charge_control_end_threshold` or `charge_stop_threshold`, and reads back the actual thresholds. Batteries exposing neither file are skipped, and the service fails only when no battery has one. A failed run is retried every 10 seconds, up to six times, to cover a battery driver that probes late. Unsupported or mismatched values fail the service, with an attempt to restore previous limits, rather than reporting success. Inspect the result with `journalctl -u dms-battery-charge-limit`. This uses native hardware limits; it does not patch the DMS UI or install a userspace charging loop. A null value leaves hardware limits unmanaged.
  When `session` is set, it declaratively manages DMS session state such as the wallpaper path under `~/.local/state/dms/session.json`.
  When `theme` is set, the whole attribute set is written as JSON to `~/.config/dms/themes/<id>/theme.json`, where `<id>` is `theme.id` (evaluation throws if it is missing). `settings.currentThemeName` and `settings.customThemeFile` are then overridden to point at that file, replacing any values passed in `settings`.
  When `lockScreenPasswordField` is set, it patches DMS's `LockAuthWidget.qml` (the file DMS 1.7 split out of `LockScreenContent.qml`) with declarative `width`, `height`, `radius`, `backgroundColor`, `backgroundOpacity`, `borderColor`, `focusBorderColor`, and `showLockIcon` values. Only the field itself is patched (its row width and height expressions), not the other uses of the same metrics for the ring, avatar, or feedback row. Any non-null value patches all eight properties: keys that are not given fall back to the module defaults (`width = 380`, `height = 60`, `radius = 18`, `backgroundColor = "#181818"`, `backgroundOpacity = 0.9`, `borderColor = "#ffffff"`, `focusBorderColor = "#ffffff"`, `showLockIcon = true`), not to upstream's styling. The value must be an attribute set; `width` and `height` must be positive numbers, `radius` non-negative, `backgroundOpacity` between 0 and 1, the colors strings, and `showLockIcon` a boolean. The authentication widget keeps its screen-width limit and style-dependent visibility. The build fails if the expected upstream expressions change instead of silently skipping customization.

- `hyprland.useDarkMode { qtUseGtkPlatformTheme ? true }`
  Enables `dconf`, sets GNOME dark mode preference, and optionally exports `QT_QPA_PLATFORMTHEME=gtk3`.

- `hyprland.useHypridle { timeToScreenOff ? 600, timeToLock ? 900, timeToSuspend ? 1800 }`
  Enables Hypridle with DPMS off, lock, and suspend listeners.

- `hyprland.useHyprland { enableXWayland ? true, monitors ? null, workspaces ? null, followMouse ? 1, pointerSpeed ? 0, enableMouseAcceleration ? false, disableHardwareCursors ? false, noCursorWarps ? true }`
  Enables Hyprland and UWSM, generates `hyprland.lua` through Home Manager, exports Wayland/IME session variables, starts `fcitx5`, and applies monitor/workspace/input/cursor settings.
  `monitors` must be a list of `hl.monitor` spec attrsets such as `{ output = "DP-3"; mode = "1920x1080@200"; position = "0x0"; scale = 1; }`.
  `workspaces` must be a list of `hl.workspace_rule` spec attrsets such as `{ workspace = "1"; monitor = "DP-3"; default = true; persistent = true; layout = "master"; }`.
  If a `hyprland` flake input is present in `specialArgs`, it uses that package and matching portal.
  `services.xserver.enable` follows `enableXWayland`, so the X server option is turned on by default.
  Provides the `hyprLua` helper (`modules/desktop/hyprland/lua-helpers.nix`) to other modules through `_module.args`.

- `hyprland.useHyprlock {}`
  Enables Hyprlock with the repo's lock-screen theme and adds `hyprlock` PAM service.
  Also runs `hyprlock` one second after every Hyprland start, so the session comes up locked.

- `hyprland.useHyprpolkit {}`
  Enables `hyprpolkitagent`.

- `hyprland.useHyprshell { modifier ? "alt" }`
  Enables Hyprshell, starts `hyprshell run`, and configures the window switcher.
  If a `hyprshell` flake input is present in `specialArgs`, it uses that package.

- `hyprland.useTrayBridge {}`
  Enables `snixembed`.

- `hyprland.useXdgMenu { prefix ? "hyprland-" }`
  Sets `XDG_MENU_PREFIX` and generates an applications menu so non-Plasma sessions can resolve desktop applications and “Open With” handlers.

- `hyprland.useXdgUserDirs { createDirectories ? true }`
  Enables Home Manager XDG user directories, exports their session variables, and optionally creates the standard Desktop, Documents, Downloads, Music, Pictures, and Videos directories.

#### `modules.desktop.hyprland.cursors`

- `hyprland.cursors.useRosePineCursor { cursorSize ? 24 }`
  Configures Rose Pine cursor themes and Hyprcursor environment variables.

#### `modules.desktop.hyprland.keybinds`

`key` arguments use the Hyprlang-style `"MODS, key"` form, for example `"SUPER SHIFT, O"`. A value without a comma, such as `"F9"`, is a bare key with no modifiers.
Helper scripts that call `hyprctl` take it from `config.programs.hyprland.package`, so they match the Hyprland build the session runs.

- `hyprland.keybinds.useDefaults { mod ? "SUPER", subMod ? "SUPER SHIFT", workspaceCount ? 7, moveWorkspaceCount ? workspaceCount }`
  Adds the repo's default Hyprland keybind pack, including workspace movement and the `hypr-smart-step` helper for tiled/floating resize and movement.
  `mod + 1..workspaceCount` focuses a workspace and `subMod + 1..moveWorkspaceCount` moves the active window to one; both counts must be integers from 0 to 9.
  `hypr-smart-step` moves and resizes by 5% of the focused monitor's on-screen size, accounting for its scale and rotation. Its `splitratio` fallback for a resize that had no effect is only sent on dwindle workspaces. `mod + mouse wheel` sends the scrolling layout's column move and does nothing on other layouts.

- `hyprland.keybinds.useDankLinuxLauncher { key ? "SUPER, D", package ? null }`
  Opens the DankMaterialShell launcher through the `spotlight toggle` IPC call.
  With `package = null` it uses the package configured by `hyprland.useDankLinux` (including its lock-screen patch), so that module must be imported too.

- `hyprland.keybinds.useKitty { key ? "SUPER, R" }`
  Binds `kitty`.

- `hyprland.keybinds.useGsrSaveReplay { key ? "ALT, F9" }`
  Binds `gsr-save-replay`.

- `hyprland.keybinds.useScreenOff { key ? "SUPER SHIFT, O", delaySeconds ? 1 }`
  Binds a delayed Lua `hl.dsp.dpms` toggle.

- `hyprland.keybinds.useHyprshot { key ? "Print" }`
  Binds region capture to `<key>` and active-window capture to `Alt+<key>` (`Print` and `Alt+Print` by default). Both captures go to the clipboard only; nothing is saved to disk.
  `key` here is the key name only; the module adds the modifiers itself.

- `hyprland.keybinds.useMediaFunctions { enableMicMute ? true, enableStop ? true, maxVolume ? "1.0", playerctlPackage ? null, sink ? "@DEFAULT_AUDIO_SINK@", source ? "@DEFAULT_AUDIO_SOURCE@", volumeStep ? "5%", wireplumberPackage ? null }`
  Binds standard media function keys with `wpctl` and `playerctl`. `hyprland.keybind.useMediaFunctions` is available as a singular alias.

- `hyprland.keybinds.useToggleMonitorSetup { settings ? [] }`
  Builds one toggle script per entry and binds each script to the configured key.
  Each entry should look like:

```nix
{
  monitorName = "eDP-1";
  defaultSetup = { output = "eDP-1"; mode = "3456x2160@60"; position = "0x0"; scale = 1.6; };
  toggleSetup = { output = "eDP-1"; mode = "3456x2160@120"; position = "0x0"; scale = 1.6; };
  key = "SUPER SHIFT, P";
}
```

  `defaultSetup` and `toggleSetup` must be `hl.monitor` spec attrsets; the helper applies them through `hyprctl eval`.
  The script decides which setup to apply by comparing the monitor's current refresh rate, rounded to an integer, with the `@<rate>` in `toggleSetup.mode`: at the toggle rate it applies `defaultSetup`, otherwise `toggleSetup`.
  Assertion: both setups need a `mode` string with an explicit `@<rate>`, and the two rounded rates must differ.
  `key` defaults to `"SUPER SHIFT, P"` per entry, and each generated script is also added to `home.packages`.

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
  When `wallpapers` is non-empty it takes precedence and `wallpaper`/`monitors` are ignored.
  Assertion: one of the wallpaper forms must resolve to a non-empty config.

- `hyprland.wallpaper.useLinuxWallpaperEngine { wallpapers, fps ? 60 }`
  Starts Linux Wallpaper Engine from the Lua `hyprland.start` event and installs a restart helper.
  Its silent mode uses SDL's dummy audio backend so muted wallpapers do not occupy a PipeWire sink.
  `wallpapers` entries should look like `{ screen = "DP-3"; wallpaper = "2798192282"; }`.
  Assertion: `wallpapers` must not be empty.

#### `modules.desktop.hyprland.windowRules`

- `hyprland.windowRules.useDefaults {}`
  Initializes the Hyprland `window_rule` setting as an empty list. It currently applies no rules.

- `hyprland.windowRules.useFixed { class, workspace }`
  Pins windows whose class matches the regex `class` to a workspace. The four `useFixed*` exports below are this module with a preset class.

- `hyprland.windowRules.useFixedDiscord { workspace }`
  Pins Discord to a workspace by class match.

- `hyprland.windowRules.useFixedSpotify { workspace }`
  Pins Spotify to a workspace by class match.

- `hyprland.windowRules.useFixedMopiMopi { workspace }`
  Pins MopiMopi to a workspace by class match.

- `hyprland.windowRules.useFixedVesktop { workspace }`
  Pins Vesktop to a workspace by class match.

- `hyprland.windowRules.useHidden { initialClass, processArgv0, initialTitle ? "", xwayland ? true, workspace ? "hidden" }`
  Isolates windows only when their backend (`xwayland`), initial class, initial title, and `/proc/<pid>/cmdline` argv[0] all match exactly. Set `xwayland = false` for native Wayland applications, including Wine's Wayland driver. Missing/unreadable process information leaves the window untouched. Class and executable must be non-empty strings; title may be empty; `xwayland` must be a boolean. Requires `useHyprland`'s `hyprLua` helper.
  A Lua `window.open_early` handler tags verified windows before initial focus/render. Tag-scoped dynamic rules disable focus, focus-on-activation, opacity, blur, shadows, decorations, and animations. The `window.open` handler moves the initialized window to `special:<workspace>` without following it; this avoids relying on static rules that have already run in Hyprland 0.56.
  `workspace` is the special workspace name without `special:` and must contain only letters, digits, underscores, or hyphens.
  Existing windows are reconciled on reload, and windows moved out are returned. If the reserved workspace is activated (including by a switcher), a deferred event handler closes it so an invisible special-workspace overlay cannot intercept normal workspace clicks. Other special workspaces are unaffected. Use a distinct workspace for each instance.
  The monitor close call uses Hyprland 0.56's Lua API. Existing windows receive the same dynamic hiding and workspace guard immediately.
  This hides the window without terminating its process; it does not remove entries from third-party task switchers or provide a security boundary.

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
  Enables Steam and optionally Gamescope and Protontricks. With `enableGamescope`, it also enables `services.ananicy` using `ananicy-cpp` with a single `nice = -20` rule for Gamescope and no default rule set.

- `programs.gaming.useWine { isWayland ? false }`
  Installs either Wayland Wine (`wineWow64Packages.waylandFull`) or the full X11-oriented set (`wineWow64Packages.full`).

#### `modules.programs.gaming.ffxiv`

- `programs.gaming.ffxiv.useCactbot {}`
  Installs Chromium webapp launchers for `Cactbot - Raidboss` and `Cactbot - Configuration`.

- `programs.gaming.ffxiv.useFFXIV { enableFileSecret ? false, enableDotNetIPv6 ? true }`
  Installs `xivlauncher-rb`; when needed, patches its desktop entry to launch with `XL_SECRET_PROVIDER=file` and/or `DOTNET_SYSTEM_NET_DISABLEIPV6=1`.

- `programs.gaming.ffxiv.useMopiMopi {}`
  Installs a `mopimopi` launcher package with a desktop entry that opens the MopiMopi overlay in Chromium.

- `programs.gaming.ffxiv.useXivMitmClientRoutes { gateway, interface, ranges ? null }`
  Wraps `xivmitm-nix.nixosModules.client` and enables client-side FFXIV routes through the given gateway/interface.

- `programs.gaming.ffxiv.useXivMitmGateway { listenPort ? 10514, incomingInterface ? null, outgoingInterface ? incomingInterface, clientCidr ? null, portRange ? "1024:65535", ranges ? null, manageDocker ? false, runContainer ? false, ffxivDx11Exe ? null, dataDir ? null, listenAddress ? null, measurePing ? null, webStatistics ? null, extraMitmArgs ? null }`
  Wraps `xivmitm-nix.nixosModules.server` and enables server-side sysctls and iptables routing for XivMitmLatencyMitigator. Non-null optional values are forwarded to the upstream server module; Docker container management stays disabled by default for raw Compose usage.

### `modules.programs.jetbrains`

- `programs.jetbrains.useIntellij { enableZshAlias ? false }`
  Installs IntelliJ IDEA and optionally defines an `idea()` zsh launcher function that starts the package's own executable in the background.

- `programs.jetbrains.usePycharm { enableZshAlias ? false }`
  Installs PyCharm (`pkgs.jetbrains.pycharm`) and optionally defines a `pycharm()` zsh launcher function.

- `programs.jetbrains.useWebstorm { enableZshAlias ? false }`
  Installs WebStorm and optionally defines a `webstorm()` zsh launcher function.

### `modules.programs.shell`

- `programs.shell.useShell {}`
  Adds Bash to `environment.shells` and sets `EDITOR=nano`.

- `programs.shell.useZsh {}`
  Enables system Zsh, sets the user shell to Zsh, enables Home Manager Zsh, `oh-my-zsh`, autosuggestions, syntax highlighting, and Powerlevel10k, whose config is sourced from the store. The system-wide `compinit` and prompt are turned off because oh-my-zsh and Powerlevel10k provide both in the user's zshrc.

### Other `modules.programs` exports

- `useAlsaUtils {}`
  Installs the ALSA command-line utilities.

- `useAntigravity {}`
  Installs Google Antigravity from the `antigravity-nix` flake input: the default package, `google-antigravity-ide`, and `google-antigravity-cli`, via `environment.systemPackages`.

- `useAyugram {}`
  Installs AyuGram Desktop.

- `useBlueman {}`
  Enables the Blueman D-Bus service and suppresses the default autostart desktop file.

- `useClaudeCode {}`
  Applies the Claude Code overlay, installs the package, configures the Home Manager module, and uses a runtime `npx` wrapper for the status line. The wrapper runs a pinned `@owloops/claude-powerline` version.
  `mutableSettings` is enabled, so `~/.claude/settings.json` stays a writable file that the declared settings are merged into on activation.

- `useClaudeDesktop { withFhs ? true, enableWayland ? false }`
  Applies the `claude-desktop` flake input overlay (aaddrick/claude-desktop-debian, a repackage of Anthropic's official Linux `.deb`) and installs Claude Desktop. With `withFhs = true` it installs `claude-desktop-fhs`, the FHS-wrapped variant that provides node, uv, docker, and similar tools for MCP servers; otherwise it installs the plain `claude-desktop` package. `enableWayland = true` sets `CLAUDE_USE_WAYLAND=1` as a session variable so the launcher uses native Wayland. App state lives under `~/.config/Claude`, which is covered by the persisted `/home`.

- `useCodex {}`
  Installs Codex CLI from the `codex-cli-nix` flake input.

- `useCodexAuth {}`
  Installs a NixOS-compatible wrapper for `codex-auth` 0.2.10. It pins and patches the upstream Linux native binary, provides Node.js 24 for API refreshes, and keeps the current system `PATH` available for invoking Codex CLI.

- `useCodexDesktop { quitOnClose ? false, enableComputerUse ? false }`
  Enables the upstream Codex Desktop Linux Home Manager module from the `codex-desktop` flake input.

  When `quitOnClose` is enabled, prevents the final Codex window from being hidden to the system tray and exits the application when that window is closed.
  When `enableComputerUse` is enabled, bundles the local Linux Computer Use backend before applying the optional close-window patch, enables AT-SPI accessibility and the `ydotool` service with uinput support, and grants the main user access to the daemon socket and direct pointer input through `/dev/uinput`. After applying the configuration and logging in again, enable Settings → Computer use → Any App in the desktop app. Remote control is not enabled by this option.

- `useCommonTools {}`
  Installs the repo's common CLI toolkit.

- `useChrome {}`
  Installs Google Chrome.

- `useChromium { commandLineArgs ? [], language ? "ko-KR", languageEnvironment ? null }`
  Enables Chromium through the NixOS `programs.chromium` module and installs a localized Chromium wrapper. By default it sets `LANGUAGE=ko_KR:ko` and passes `--lang=ko-KR`; `language = null` disables both language settings. `languageEnvironment` can override the generated `LANGUAGE` value.

- `useDirenv {}`
  Enables Home Manager Direnv with Bash, Zsh, and `nix-direnv` integration.

- `useDiscord {}`
  Installs the stock Discord package unchanged. The XWayland/fcitx desktop-entry override for IME behavior is kept in the file but commented out.

- `useDolphin { withSilentKdeDeps ? false }`
  Installs KDE Dolphin. When `withSilentKdeDeps = true`, wraps it with the KService, KDE CLI, and KIO data needed for working “Open With” handlers outside Plasma while suppressing cache rebuild output.

- `useEquibop { package ? null }`
  Installs Equibop and registers it as the default handler for `x-scheme-handler/discord`.

- `useFastfetch { beforeModules ? [], afterModules ? [] }`
  Installs Fastfetch and writes a JSON config with custom module lists prepended/appended around the repo default layout.

- `useFirefox { enableWidevine ? false }`
  Enables Firefox, optionally overlays `aarch64-widevine`, and sets `MOZ_GMP_PATH` when `enableWidevine = true`.
  `MOZ_GMP_PATH` points into `pkgs.widevine-cdm-lacros`, which only the `aarch64-widevine` overlay provides, so `enableWidevine = true` needs that input in `specialArgs`. Hosts that leave it off do not have to pass the input.

- `useForgeCode { enableZshIntegration ? false }`
  Installs ForgeCode from `modules/programs/forge-code/pkg.nix`, which wraps the prebuilt upstream release binary rather than building from source, installs helper tools, sets `FORGE_BIN`, and optionally injects ForgeCode Zsh integration.
  On Home Manager activation it removes installer leftovers: the installer's lines in `~/.bashrc`, and `~/.local/bin/forge` when that is a regular file rather than a symlink.

- `useGit { name, email }`
  Enables Git and Git LFS in Home Manager, sets user identity and default branch, and enables GitHub CLI with credential helper.

- `useGptOauthServer { host ? "127.0.0.1", port ? 10531, version ? "1.0.1", authFile ? null, models ? null, codexVersion ? null, baseUrl ? null, oauthClientId ? null, oauthTokenUrl ? null, extraArgs ? [] }`
  Installs a `gpt-server` wrapper that runs `npx --yes openai-oauth@${version}` with the configured defaults and forwards extra runtime arguments. It listens on loopback by default; pass `host = "0.0.0.0"` to serve other machines.
  Assertions: `host` must be a non-empty string, `port` an integer from 1 to 65535, `models` null or a list of strings, and `extraArgs` a list of strings.

- `useHaruna {}`
  Installs Haruna.

- `useHyprshot {}`
  Installs Hyprshot.

- `useK3b {}`
  Installs K3b.

- `useKcalc { enableWindowsAlias ? false }`
  Installs KCalc and optionally creates a `calc` desktop entry alias.

- `useKitty {}`
  Installs Kitty and writes the repo's `kitty.conf` into Home Manager.

- `useKolourpaint { enableWindowsAlias ? false }`
  Installs KolourPaint and optionally creates a `pbrush` desktop entry alias.

- `useLact { enableDaemon ? true, persistPath ? null }`
  Installs LACT. With `enableDaemon`, enables the NixOS `services.lact` module (the `lactd` unit) and persists `/etc/lact`, where the daemon keeps fan curves and tuning.

- `useLibreOffice {}`
  Installs a wrapped `libreoffice-qt` package that forces the Qt6 VCL backend and avoids global Qt style overrides.

- `useMoonlight {}`
  Installs Moonlight Qt.

- `useNixIndex {}`
  Enables Home Manager `nix-index` with Bash and Zsh integration.

- `useNmApplet {}`
  Installs `networkmanagerapplet`.

- `useObsidian {}`
  Installs Obsidian.

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
  When `enableDefaultConfig = false`, it writes the Home Manager legacy `Host *` defaults explicitly. A `"*"` entry in `settings` replaces that whole default block instead of being merged with it.

- `useSpotify { withAlsaExclusive ? {} }`
  Installs Spotify on most systems, or `spotify-qt` plus `librespot` on `aarch64-linux`. On `aarch64-linux`, it patches `spotify-qt.json` if that file already exists; a file that cannot be parsed is left untouched.
  Set `withAlsaExclusive = { enable = true; pipewire-target = "<sink node.name>"; profile ? null; rate ? 44100; suspend-existing ? false; parking-target ? "spotify-exclusive-park"; }` to additionally install the `spotify-alsa` command and the `Spotify: Alsa Exclusive` desktop entry. The command optionally activates a `pipewire-profile` and injects the exclusive target, clock, and DSP-bypass properties directly into Spotify's normal PulseAudio stream. With `suspend-existing = true`, the module creates a silent virtual parking sink. Existing PulseAudio-compatible streams are moved there, native PipeWire links are temporarily disconnected, and the parking sink becomes the default so clients opened during the session stay silent instead of taking the hardware target. The original default and stream routing are restored when Spotify exits or fails. This avoids restarting the shared `pipewire-pulse` server while still disabling remixing, resampling, fallback routing, and dither. Spotify's `FLOAT_LE` output is still converted to the hardware format by PipeWire.
  `profile` is activated through the `pipewire-profile` command, which this module does not install; it comes from `modules.services.pipewire.useProfileChanger` and must be on `PATH` at run time.
  Assertions when `enable = true`: the host must not be `aarch64-linux`, PipeWire with PulseAudio compatibility must be enabled, `pipewire-target` must be a sink node name without whitespace, `profile` must be null or a non-empty string, `rate` must be a positive integer, `suspend-existing` must be a boolean, and with `suspend-existing = true` the `parking-target` must be a valid sink node name different from `pipewire-target`.

- `useTauon {}`
  Installs Tauon.

- `useThunderbird { package ? null }`
  Enables Thunderbird through the NixOS `programs.thunderbird` module.

- `useVesktop {}`
  Installs a Vesktop variant with Wayland IME flags baked into the desktop entry.

- `useVscode {}`
  Installs VS Code.

- `useVim { enableGui ? true }`
  Configures Neovim through integrated Home Manager and optionally installs the Neovide GUI with a Nerd Font. Neovide explicitly launches the Home Manager configured Neovim package.
  Nix installs all plugins, Tree-sitter parsers, language servers, and formatters; no Lazy/Mason runtime installation is used. Includes a file tree, project search, completion, Git changes and LazyGit, GitHub PR/issue integration through Octo and the existing `gh` login, and manual formatting.
  The desktop-style layout has clickable File/Edit/View/Go/Code/Git/Help menus, file tabs with modified indicators, a persistent left sidebar with Files/Git/Open selectors, and a bottom status bar and terminal. File closing preserves the sidebar and prompts to save/discard/cancel; file paths and choices use floating dialogs. A searchable command palette is available through the Help menu.
  Neovide uses GUI editing controls: file buffers start in Insert mode, Shift+navigation and mouse dragging select text, and Ctrl+A/C/X/V/Z/Y provide selection, clipboard, undo, and redo. Ctrl+N/O/S/W, Ctrl+Tab, Ctrl+F/H, and Ctrl+Shift+P handle files, tabs, search/replace, and the command palette. F4 also opens the command palette; rflxn-desktop uses Super+Ctrl+P for screen power to avoid a conflict. Esc still enters Normal mode. Terminal Neovim retains modal editing controls. Alt+1/2/3 switches sidebar views, and F1 opens the usage guide.
  Language servers cover JavaScript/TypeScript, Python, Java, Nix, Lua, Bash, JSON, HTML/CSS, C/C++, Rust, and Go. JDT LS gets a separate writable cache directory per project. Project runtimes and dependencies should still be supplied by the project's environment; editor tools are appended to PATH.
  Launch `neovide` for the GUI or `nvim` in a terminal. `F1` opens the local quick-start guide; Space is the leader key. This module leaves the default editor, existing VS Code installation, and MIME associations unchanged. User state remains under the user's XDG directories, covered by this repository's `/home` persistence.

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
  Enables PipeWire with ALSA, PulseAudio, and JACK support. 32-bit ALSA support is enabled on `x86_64` only.

- `services.pipewire.useDenoisedMic {}`
  Adds an `rnnoise` filter-chain source called `Noise Canceling Source`.

- `services.pipewire.useLowLatency { defaultRate ? 48000, allowedRates ? [ 44100 48000 88200 96000 176400 192000 ], defaultQuantum ? 256, minQuantum ? 64, maxQuantum ? 2048 }`
  Configures a flexible PipeWire clock range suitable for runtime profile switching.
  Assertions require positive rates and ordered quantum bounds, and `allowedRates` must include `defaultRate`.

- `services.pipewire.useProfileChanger { profiles, defaultProfile ? null }`
  Installs the `pipewire-profile` CLI and a persistent StatusNotifierItem tray service.
  Profile entries look like `{ name, label ? name, description ? label, icon ? "audio-card", rate ? null, quantum ? null, deviceProfiles ? [], startUserServices ? [], stopUserServices ? [] }`.
  `deviceProfiles` entries look like `{ device, profile, required ? false }`, where `device` is a stable PipeWire `device.name`. A null clock value releases the corresponding PipeWire runtime override.
  The selected profile is remembered and continuously enforced across PipeWire restarts and USB device reconnections.
  `defaultProfile = null` selects the first entry in `profiles`.
  Assertions: PipeWire must be enabled; `profiles` must not be empty; profile names must be unique and match `[A-Za-z0-9][A-Za-z0-9._-]*`; `label` and `icon` must be non-empty strings; `rate` and `quantum` must be null or positive integers; each `deviceProfiles` entry needs non-empty `device` and `profile` strings and a boolean `required`; `startUserServices` and `stopUserServices` must be lists of non-empty strings with no service in both; and `defaultProfile` must name one of the profiles.

### Other `modules.services` exports

- `useDocker { isBtrfs ? false, isRootless ? false, containersAsService ? {}, persistPath ? null }`
  Enables the system Docker daemon (started on boot), optionally uses the `btrfs` storage driver, optionally defines `virtualisation.oci-containers` with the Docker backend, and persists `/var/lib/docker`.
  With `isRootless = false`, the repo user is added to the `docker` group. With `isRootless = true`, rootless Docker is enabled with `DOCKER_HOST` set for the user, in addition to the system daemon rather than instead of it; the persisted `/var/lib/docker` belongs to the system daemon, while rootless data stays under the user's home.
  `containersAsService` is passed through to `virtualisation.oci-containers.containers`.

- `useDeluge { authFile ? null, downloadDir ? null, webAuthFile ? null, webHost ? "0.0.0.0", webPort ? 8112, allowRemote ? false, persistPath ? null }`
  Enables Deluge and its web UI in non-declarative mode, running as the repo user and primary group, without opening the firewall, and persists `/var/lib/deluge`.
  `downloadDir = null` falls back to `/home/${username}/data/torrents`.
  `deluged` rewrites `core.conf` on every start with `allow_remote = allowRemote` and the download location, so settings changed in the client are reset. `allowRemote = false` keeps the daemon RPC port on loopback, which is all the web UI needs; set it to `true` for thin clients on other machines.
  When `authFile` is set, it is copied to `auth` on every start.
  When `webAuthFile` is set, `delugeweb` regenerates `web.conf` on every start from `webHost`, `webPort`, and the `pwd_salt`/`pwd_sha1` keys of `webAuthFile`, which must be a JSON object containing both. Without `webAuthFile`, only `webPort` is applied.
  Assertion: a non-default `webHost` requires `webAuthFile`, because the host is only written together with the web password.

- `useEasyEffects { preset ? "", extraPresets ? {} }`
  Enables the Home Manager EasyEffects user service and the system dconf integration it requires. EasyEffects stores its settings and presets under the user's XDG directories, so this module does not add `/var` persistence.
  Assertion: PipeWire must be enabled.

- `useFlatpak { persistPath ? null }`
  Enables Flatpak and persists `/var/lib/flatpak`.

- `useGpuScreenRecorder { window ? "screen", framerate ? 60, replaySeconds ? 300, replayStorage ? "ram", restartReplayOnSave ? false, bitrateMode ? "cbr", bitrate ? 40000, quality ? "high", container ? "mp4", audioSource ? "default_output", makeDateFolders ? false, postSaveScript ? null, outputDir ? null }`
  Enables the upstream NixOS GPU Screen Recorder capability wrapper, creates a replay-mode user service, and adds a `gsr-save-replay` helper that signals only the service's main process. `bitrate` is used as the CBR kbps value; `quality` is used for the other bitrate modes.
  `outputDir = null` falls back to `/home/${username}/Videos/replays`. A `gsr-save-replay` desktop entry is installed alongside the helper.
  Assertions: `framerate` must be a positive integer; `replaySeconds` must be between 2 and 86400; `replayStorage` must be `ram` or `disk`; `bitrateMode` must be `auto`, `qp`, `vbr`, or `cbr`; `bitrate` must be a positive integer in every mode; and `quality` must be `medium`, `high`, `very_high`, or `ultra` unless `bitrateMode = "cbr"`.

- `useHomeManager { stateVersion ? "25.11", backupCommand ? null }`
  Imports the Home Manager NixOS module, sets `useGlobalPkgs` and `useUserPackages`, enables `programs.home-manager`, and configures backup behavior.

- `useJetbrainsRemote { ides ? [] }`
  Enables Home Manager JetBrains Remote and forwards the `ides` list.

- `useKeyd { settings ? {} }`
  Enables Keyd and sets `services.keyd.keyboards = settings`.

- `useLibinput {}`
  Enables libinput.

- `useLinuxWallpaperengine { wallpapers, fps ? 60 }`
  Creates a user service for Linux Wallpaper Engine and installs a `restart-wallpaper` helper.
  `wallpapers` entries should look like `{ screen = "DP-3"; wallpaper = "2798192282"; }`.
  This is the systemd-service variant; `modules.desktop.hyprland.wallpaper.useLinuxWallpaperEngine` is the variant started from Hyprland's Lua `hyprland.start` event.

- `useNginX { upstreams ? {} }`
  Alias for `services.nginx.useNginX`.

- `useRemovableStorageAutoMount { mountOnMedia ? false, notify ? true, tray ? "auto" }`
  Enables `udisks2`, installs `udiskie`, and starts the Home Manager `udiskie` user service with automatic mounting enabled.
  By default, removable devices mount under `/run/media/$USER`; set `mountOnMedia = true` to use `/media`.

- `useRtkit {}`
  Enables realtime kit.

- `useSamba { directories ? {}, persistPath ? null }`
  Enables Samba with one share per entry in `directories`, forces ownership to the repo user and primary group, and persists `/var/lib/samba`.
  `directories` should look like `{ data = "/home/rflxn/data"; }`.
  Assertion: `directories` must not be empty.

- `useSpotifySoloist { keyFile, deviceName ? null, initialVolume ? null, pipewireDevice ? null, cacheSize ? null, websocketAddress ? null, verbose ? false, extraArgs ? [] }`
  Runs Spotify Soloist, the headless Spotify Connect receiver, as a `spotify-soloist` systemd user service bound to `graphical-session.target`, so audio goes through the user's PipeWire session. The upstream `services.soloist` module is intentionally not used because it requires system-wide PipeWire. The service reads the Soloist developer API key from `keyFile` at start time; the file must be readable by the repo user. `deviceName` defaults to `networking.hostName`. Also installs `soloist` for `soloist ctl`. State and cache live under `~/.local/share/soloist` and `~/.cache/soloist`, which are covered by the persisted `/home`, so the module does not add persistence entries.
  Assertions: `keyFile` must be an absolute path given as a string (a Nix path literal is rejected), the resolved device name must be a non-empty string, `initialVolume` must be 0–100, `pipewireDevice` must be null or a non-empty string, `cacheSize` must be 0 or ≥ 100, `websocketAddress` must be `ADDR:PORT`, `verbose` must be a boolean, `extraArgs` must be a list of strings, and PipeWire must be enabled.

- `useSsh { persistPath ? null, allowPasswordLogin ? false }`
  Enables OpenSSH, disables root login, and persists host keys. `allowPasswordLogin` controls both `PasswordAuthentication` and `KbdInteractiveAuthentication`, so `false` leaves key-based login only.

- `useSyncthing { devices ? {}, folders ? {}, serviceLevel ? "user", webHost ? "127.0.0.1", webPort ? 8384, persistPath ? null }`
  Enables Syncthing either as a Home Manager user service or a NixOS system service depending on `serviceLevel`.
  `serviceLevel` must be `"user"` or `"system"`; any other value fails evaluation.
  The GUI listens on loopback by default. Pass `webHost` to expose it, and set GUI credentials in Syncthing first: this module declares none.
  The system service runs as the repo user, and its persisted `/var/lib/syncthing` is created owned by that user.
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

- `useTailscale { persistPath ? null, enableSystemTray ? false, openFirewall ? false }`
  Enables Tailscale, optionally opens its UDP transport port through the NixOS firewall, optionally adds a user systray service with `--operator=${username}`, and persists `/var/lib/tailscale`.

- `useVscodeServer {}`
  Imports the `nixos-vscode-server` module and enables the service.

## Internal Helpers And Non-Exported Files

These files exist in the tree but are not part of the exported `modules` API:

- `modules/desktop/default-apps/utils.nix`
  Provides `mkMimeDefaults` and `mkMimeApps`.

- `modules/programs/forge-code/pkg.nix`
  Package derivation used by `useForgeCode`.

- `modules/services/nginx/vhosts/port-redirect-helper.nix`
  Shared reverse-proxy helper used by the built-in Deluge and Syncthing vhosts.

- `modules/desktop/qt/theme/matcha-kdeglobals.nix`
  The `kdeglobals` color groups written by `qt.theme.useMatcha`, kept as data.

- `modules/programs/gaming/ffxiv/chromium-webapp.nix`
  Builds a Chromium `--app` launcher with its own profile directory and desktop entry; used by `useCactbot` and `useMopiMopi`.

- `modules/desktop/hyprland/lua-helpers.nix`
  The `hyprLua` helper set (`bind`, `bindWith`, `execBind`, `execBindWith`, `onStart`, `toLua`, `lua`, `keyFromHyprlang`). Imported by `hyprland.useHyprland` and injected through `_module.args.hyprLua`.

- `modules/services/syncthing/system-service.nix` and `modules/services/syncthing/user-service.nix`
  The two branches selected by `useSyncthing`'s `serviceLevel`.

Non-Nix assets read by their neighbouring module are likewise internal: `dank-linux/battery-charge-limit.py`, `hyprshell/styles.css`, and `window-rules/hidden.lua` under `modules/desktop/hyprland`; `claude-code/claude-powerline.json`, `kitty/kitty.conf`, `shell/zsh/p10k.zsh`, `spotify/exclusive-session.py`, and `vim/{init,layout,gui}.lua` under `modules/programs`; and `modules/services/pipewire/profile-changer.py`.

## Current API Constraints

- `services.useSyncthing.persistPath` only affects the `serviceLevel = "system"` branch.
- `services.useNginX` and `services.nginx.useNginX` are the same export surface.
- `hyprland.keybind` and `hyprland.keybinds` are the same export surface.
- `hyprland.useHyprlock`, `hyprland.useHyprshell`, every `hyprland.keybinds.*` export, `hyprland.wallpaper.useLinuxWallpaperEngine`, and `hyprland.windowRules.useHidden` fail to evaluate without `hyprland.useHyprland`.
- `hyprland.keybinds.useDankLinuxLauncher` with `package = null` fails to evaluate without `hyprland.useDankLinux`.
- `services.useDeluge.webHost` only takes effect with `webAuthFile`.
- `hardware.useAmdGpu` does not enable `hardware.graphics`; pair it with `hardware.useGraphics`.
- `qt.theme.useRosePine`'s `kvantum*` arguments only take effect with `useOverlay = true`.
