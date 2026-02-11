# NixOS Flake Modules API Reference

All modules follow the curried function pattern:
```nix
{ arg ? default }: { pkgs, lib, ... }: { /* NixOS config */ }
```

---

## desktop

### plasma6 (object)

- **usePlasma6** `{ overrideConfig ? false, excludePackages ? [], enableSddmIntegration ? true, persistPath ? null }`
  - KDE Plasma 6 desktop environment

#### plasma6.kwin (object)

- **useBlur** `{ strength ? 5 }`
- **disableWindowBarrier** `{ }`

#### plasma6.shortcuts (object)

- **useKitty** `{ key }` - required
- **useGsrSaveReplay** `{ key }` - required
- **useRestartWallpaper** `{ key }` - required

#### plasma6.theme (object)

- **useLeaf** `{ }`

---

- **useSddm** `{ enableHidpi ? false }`
- **useXdgPortal** `{ enableKdeSupport ? false }`

---

## services

### pipewire (object)

- **usePipewire** `{ }`
- **useLowLatency** `{ }`
- **useDenoisedMic** `{ }`

---

- **useLibinput** `{ }`
- **useHomeManager** `{ stateVersion ? "25.11", backupCommand ? null }`
- **useDocker** `{ isBtrfs ? false, isRootless ? false, containersAsService ? {}, persistPath ? null }`
- **useTailscale** `{ persistPath ? null }`
- **useSyncthing** `{ devices ? {}, folders ? {}, serviceLevel ? "user", persistPath ? null }`
  - serviceLevel: `"user"` | `"system"`
- **useKeyd** `{ settings ? {} }`
- **useSsh** `{ persistPath ? null, allowPasswordLogin ? false }`
- **useJetbrainsRemote** `{ ides ? [] }`
- **useVscodeServer** `{ }`
- **useGpuScreenRecorder** `{ window ? "screen", framerate ? 60, replaySeconds ? 300, quality ? "high", container ? "mp4", audioSource ? "default_output", outputDir ? null }`
- **useRtkit** `{ }`
- **useLinuxWallpaperengine** `{ wallpapers, fps ? 60 }` - wallpapers required
  - wallpapers: `[{ screen: string, wallpaper: string }]`

---

## programs

### shell (object)

- **useShell** `{ }`
- **useZsh** `{ }`

### jetbrains (object)

- **useWebstorm** `{ enableZshAlias ? false }`
- **useIntellij** `{ enableZshAlias ? false }`
- **usePycharm** `{ enableZshAlias ? false }`

### gaming (object)

- **useSteam** `{ enableGamescope ? false, enableProtontricks ? false }`
- **useR2modman** `{ }`
- **useProtonplus** `{ }`
- **useLsfgVk** `{ }`
- **useWine** `{ isWayland ? false }`

---

- **useFirefox** `{ }`
- **useVscode** `{ }`
- **useClaudeCode** `{ }`
- **useKitty** `{ }`
- **useGit** `{ name, email }` - both required
- **useFastfetch** `{ beforeModules ? [], afterModules ? [] }`
- **useDiscord** `{ }`
- **useSpotify** `{ }`
- **useNixIndex** `{ }`
- **useDirenv** `{ }`
- **useCommonTools** `{ }`
- **useHaruna** `{ }`
- **useKcalc** `{ enableWindowsAlias ? false }`
- **useKolourpaint** `{ enableWindowsAlias ? false }`
- **useLact** `{ enableDaemon ? true }`
- **useWaylandUtils** `{ }`
- **useAyugram** `{ }`

---

## hardware

- **useGraphics** `{ }`
- **useBluetooth** `{ persistPath ? null }`
- **useAmdGpu** `{ enable32Bit ? true, enableOverdrive ? false }`
- **useOpenrazer** `{ }`

---

## system

### boot (object)

- **useEfiBoot** `{ canTouchEfiVariables ? false }`
- **useSystemdBoot** `{ consoleMode ? null, configurationLimit ? 15 }`
- **useLanzaboote** `{ persistPath ? null }`
- **usePlymouth** `{ theme ? "breeze", enableQuietBoot ? true }`

### nix (object)

- **useExperimentalFeatures** `{ }`
- **useUnfreePackage** `{ }`
- **useGc** `{ dates }` - required
- **useOptimise** `{ dates }` - required

---

- **useNetworkManager** `{ useWifi ? false, persistPath ? null }`
- **useZram** `{ memoryPercent ? 25, priority ? 10 }`
- **useImpermanence** `{ rootUuid, persistPath ? null, directories ? [], files ? [] }` - rootUuid required
- **useMe** `{ hashedPassword ? null, hashedPasswordFile ? null, extraGroups ? [] }`
- **useFcitx5** `{ }`
- **useCjkFonts** `{ }`
