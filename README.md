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
- selected flake inputs needed by each host, such as `home-manager`, `impermanence`, `rflxn-shell`, `distro-grub-themes`, `aarch64-widevine`, and `vscode-server`

Host composition style:

- `hosts/rflxn-desktop/` splits its config into `desktop.nix`, `services.nix`, `programs.nix`, and `systems.nix`
- `hosts/rflxn-asahi/configuration.nix` composes most modules inline because the machine is more specialized
- `hosts/rflxn-server/configuration.nix` keeps most of the headless service stack in one place

## Flake Overview

`flake.nix` currently tracks:

- `nixpkgs = github:NixOS/nixpkgs/nixos-unstable`
- `apple-silicon`
- `home-manager`
- `impermanence`
- `flake-utils-systems-linux`
- `vscode-server`
- `lanzaboote`
- `distro-grub-themes`
- `aarch64-widevine`
- `rflxn-shell`
- `claude-code`
- `codex-cli-nix`
- `codex-desktop`
- `battery-logger`
- `xivlauncher-rb`
- `xivmitm-nix`

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
- Session stack: Hyprland from nixpkgs with UWSM, greetd autologin, QuickShell, Hyprshell, Hyprlock, and Hyprpolkit
- Display layout: `DP-3` and rotated `HDMI-A-1`; workspaces `1` to `7` use `master` on `DP-3`, while workspace `8` uses vertical `scrolling` on `HDMI-A-1`
- Theme: Matcha GTK and Qt/Kvantum, Papirus icons, and the Rose Pine cursor/hyprcursor theme
- Wallpaper and rules: Linux Wallpaper Engine per monitor; Discord, MopiMopi, Spotify, and Vesktop are assigned to workspace `8`
- Services: PipeWire with low-latency and denoised-mic config, Docker with both the system daemon and rootless user daemon enabled, Flatpak, GPU Screen Recorder, keyd, removable-storage automounting, Home Manager, Syncthing user service, Tailscale, and rtkit
- Programs: browsers, IDEs, AI tooling including Codex CLI/Desktop, gaming tools, media tools, and general desktop apps
- System: EFI GRUB with the NixOS distro theme, Plymouth, the latest nixpkgs kernel, impermanence, NetworkManager with iwd, zram, AMD GPU overdrive support, Bluetooth, and shared font and IME setup
- Secure Boot: the Lanzaboote input and reusable module remain available, but the desktop host does not currently import the module

### `rflxn-asahi`

- Platform: `aarch64-linux`
- Role: Apple Silicon laptop
- Session stack: Hyprland from nixpkgs with UWSM, greetd autologin, QuickShell, Hyprshell, Hypridle, Hyprlock, Hyprpolkit, and the tray bridge
- Input and display: built-in `eDP-1`, touchpad defaults, 3-finger workspace gesture, and Mac-style key remaps through keyd
- Monitor toggle: `SUPER SHIFT, P` switches `eDP-1` between `60 Hz` and `120 Hz`
- Firmware: the Apple peripheral firmware extraction step expects `all_firmware.tar.gz` and `kernelcache*`; see the firmware caveat below
- Services: PipeWire, Docker with both the system daemon and rootless user daemon enabled, Flatpak, keyd, libinput, removable-storage automounting, rtkit, Home Manager, Syncthing user service, and Tailscale with systray support and its UDP transport port open
- Programs: desktop and development tools, including Firefox with aarch64 Widevine support
- System: Apple Silicon support module, EFI with `canTouchEfiVariables = false`, systemd-boot, impermanence, NetworkManager Wi-Fi, Bluetooth, graphics with `enable32Bit = false`, zram, shared font and IME setup
- Battery logger: the input and reusable module are present, but the host import is currently commented out

### `rflxn-server`

- Platform: `x86_64-linux`
- Role: headless server, remote development host, and sync box
- Services: Docker, Cloudflare DDNS OCI container, Home Manager, JetBrains Remote, SSH, Samba, Tailscale, VS Code server, Syncthing system service, Deluge, and nginx
- Reverse proxy: nginx exposes Deluge under `/torrent` and Syncthing under `/syncthing` over plain HTTP on port `80`
- Programs: zsh, git, direnv, nix-index, Claude Code, and common CLI tooling
- System: EFI, systemd-boot, impermanence, and standard nix cache, GC, and optimise settings
- Network role: XIVMitm gateway rules assume server interface `enp5s0`, server address `192.168.100.100`, and desktop client `192.168.100.101`; the fixed addressing or DHCP reservation is managed outside this repository

## Build and Inspection

```bash
# Inspect the flake
nix flake show
nix flake check --no-build

# Build without switching
nix build .#nixosConfigurations.rflxn-desktop.config.system.build.toplevel
nix build .#nixosConfigurations.rflxn-asahi.config.system.build.toplevel
nix build .#nixosConfigurations.rflxn-server.config.system.build.toplevel

# Switch
sudo nixos-rebuild switch --flake .#rflxn-desktop
sudo nixos-rebuild switch --flake .#rflxn-asahi
sudo nixos-rebuild switch --flake .#rflxn-server
```

`nix flake check --no-build` verifies evaluation, not the availability or buildability of every runtime asset. In particular, check the Asahi firmware caveat before relying on a successful evaluation.

## Prerequisites and Secrets

### Global

1. The hosts assume `btrfs` subvolumes named `@root`, `@root-blank`, `@nix`, and `@persist`. The server keeps `@persist` on a separate Btrfs filesystem from `@root`.
2. `/persist` is the default persistence root passed into modules.
3. Create the user password hash file:

```bash
mkdir -p /persist/secrets
mkpasswd -m sha-512 > /persist/secrets/rflxn.hashedPassword
```

### Desktop (`rflxn-desktop`)

- The active boot loader is GRUB. Lanzaboote and Secure Boot are not currently enabled by the host.
- If Lanzaboote is enabled later, create and enroll `sbctl` keys first. The reusable Lanzaboote module persists `/var/lib/sbctl`.

### Asahi (`rflxn-asahi`)

The Apple Silicon support module expects these non-redistributable firmware files:

- `all_firmware.tar.gz`
- one or more `kernelcache*` files

The current configuration points at `hosts/rflxn-asahi/firmware`, while that directory's `.gitignore` excludes all firmware files. Because `.gitignore` itself is tracked, the directory-existence check succeeds even when the required files are absent. Git-backed flake evaluation also excludes ignored files from the copied Nix store source.

Consequently, copying firmware into the ignored directory is not sufficient for a normal pure `nix build .#...`: the firmware must be supplied through a source visible to the flake, such as a deliberately managed private source or an explicit external/impure path after adjusting the host configuration. A successful `nix flake check` alone does not validate this firmware payload.

### Server (`rflxn-server`)

- Cloudflare DDNS expects:

```bash
mkdir -p /persist/secrets
printf 'API_KEY=your_cloudflare_api_token\n' > /persist/secrets/ddns.env
```

- Deluge expects:
  - `/persist/secrets/deluge.auth` in Deluge `auth` file format
  - `/persist/secrets/deluge-web.auth` as JSON with `pwd_salt` and `pwd_sha1`

## Current Security And Network Posture

Desktop and Server currently assume a trusted home network, while Asahi treats its physical networks as untrusted:

- Desktop and Server keep `networking.firewall.enable = false`; their LAN and permitted tailnet peers can reach listening services.
- Asahi enables the stateful firewall, trusts incoming traffic on `tailscale0`, and opens UDP `41641` on physical interfaces for direct Tailscale transport.
- Desktop and Asahi bind the Syncthing GUI to `0.0.0.0:8384`; Asahi's physical interfaces are blocked by its firewall, while permitted tailnet peers can still reach the GUI. GUI authentication is not enforced declaratively by this repository.
- Server nginx listens on the default all-interface HTTP port `80` and proxies `/torrent` and `/syncthing` without TLS at the proxy layer.
- Server SSH permits password authentication, and Deluge enables remote daemon access.
- The desktop GPU Screen Recorder module currently grants passwordless Polkit authorization by matching any executable path containing `gpu-screen-recorder`. Treat this as a local privilege-escalation risk until the rule is removed or restricted to an exact immutable path.

Actual internet reachability still depends on routing, NAT, IPv6, and upstream firewall rules. Review Desktop and Server bindings before exposing either host beyond the trusted home network.

## Troubleshooting

### Recover missing m1n1 payload on `rflxn-asahi`

If the Asahi machine stops before systemd-boot and the boot log ends around
`Running proxy...`, the stage-1 m1n1 loader may be unable to find the stage-2
payload at `m1n1/boot.bin` on the NixOS EFI system partition.

From macOS, mount the NixOS EFI partition and check whether the `m1n1` directory
is missing:

```zsh
diskutil list internal
diskutil mount <nixos-efi-partition>
ls -la "/Volumes/EFI - NIXOS"
```

If the mounted partition contains `EFI/`, `loader/`, `vendorfw/`, and `asahi/`
but no `m1n1/`, install a temporary UEFI-only payload:

```zsh
ESP="/Volumes/EFI - NIXOS"
PKG_URL="https://cdn.asahilinux.org/os/uefi-only-20260301-asahi-6.18.10-1.zip"

work="$(mktemp -d /tmp/asahi-m1n1.XXXXXX)"
curl -fL --progress-bar -o "$work/uefi-only.zip" "$PKG_URL"
ditto -x -k "$work/uefi-only.zip" "$work/extracted"

sudo mkdir -p "$ESP/m1n1"
sudo cp -f "$work/extracted/esp/m1n1/boot.bin" "$ESP/m1n1/boot.bin"
sync
diskutil unmount "$ESP"
```

This payload is only for recovery. After NixOS boots, reinstall the payload from
the current NixOS generation:

```bash
sudo mkdir -p /boot/m1n1
sudo /run/current-system/bin/switch-to-configuration switch
sudo reboot
```

## Module API

See [API.md](./API.md) for the detailed module API reference.

## QuickShell Workflow

Current behavior of `modules/desktop/hyprland/quickshell/default.nix`:

- The module imports `rflxn-shell.nixosModules.default`.
- Home Manager enables `services.rflxn-shell`.
- Host files pass monitor-specific `services.rflxn-shell.configs` data.
- Home Manager starts `rflxn-shell.service` as a user systemd service.
