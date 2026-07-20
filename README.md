# RFLXN's NixOS Configuration

## Overview

RFLXN's multi-system NixOS configuration repository. One flake manages three machines while a shared module library keeps reusable behavior separate from host-specific composition.

| Host | Platform | Role |
| --- | --- | --- |
| `rflxn-desktop` | `x86_64-linux` | Hyprland workstation and gaming desktop |
| `rflxn-asahi` | `aarch64-linux` | Apple Silicon laptop running NixOS with Asahi support |
| `rflxn-server` | `x86_64-linux` | Headless storage, sync, remote-development, and network-services server |

The flake entry point is [`flake.nix`](./flake.nix). Host definitions live under [`hosts/`](./hosts), and the reusable module library is exported from [`modules/default.nix`](./modules/default.nix).

## Module–Host Composition

### Two-stage curried modules

Most modules use a two-stage curried function:

```nix
{ optionA ? defaultA, ... }:
{ config, lib, pkgs, username, ... }:
{
  # NixOS or Home Manager configuration
}
```

The two layers have different responsibilities:

1. The first attribute set is the module's repository-local API. A host supplies simple values such as ports, devices, feature switches, or persistence paths.
2. The second attribute set receives the normal NixOS module arguments from `nixosSystem`, including `config`, `lib`, `pkgs`, and values passed through `specialArgs`.

Calling the first layer returns a regular NixOS module, so hosts can compose configured modules directly in `imports`:

```nix
{ modules, ... }:
{
  imports = with modules.services; [
    (useDocker {
      isBtrfs = true;
      isRootless = true;
    })
    (useTailscale {})
  ];
}
```

`flake.nix` imports the module tree once and passes it to every host as `specialArgs.modules`. It also passes shared values such as `username`, locale, timezone, Syncthing device IDs, and `defaultPersistPath`.

### Why this structure is used

![Three-host module composition](./vdg.jpg)

In the diagram, Host A represents `rflxn-desktop`, Host B represents `rflxn-asahi`, and Host C represents `rflxn-server`.

- The center represents modules shared by all three hosts, such as user creation, Nix settings, impermanence, and common CLI tools.
- Pairwise overlaps represent features shared by only two hosts, such as the Hyprland desktop stack or selected network services.
- The non-overlapping areas remain host-specific: AMD gaming configuration, Apple Silicon support and firmware, or headless server services.

This keeps reusable behavior independent of host names, makes differences visible at each host's `imports`, and avoids one large module filled with per-machine conditionals. Each host can reuse the same module with its own first-layer arguments.

```text
.
├── flake.nix
├── hosts/
│   ├── rflxn-desktop/
│   ├── rflxn-asahi/
│   └── rflxn-server/
└── modules/
    ├── desktop/
    ├── hardware/
    ├── programs/
    ├── services/
    └── system/
```

## Hosts

### `rflxn-desktop`

- AMD `x86_64-linux` desktop with Hyprland, UWSM, greetd autologin, QuickShell, and a two-monitor workspace layout.
- Uses EFI GRUB with Plymouth, the latest nixpkgs kernel, Btrfs impermanence, NetworkManager, zram, and AMD GPU overdrive.
- Includes desktop applications, development tools, Steam/Wine tooling, GPU Screen Recorder, FFXIV tooling, Syncthing, and Tailscale.
- Composition is split into `desktop.nix`, `programs.nix`, `services.nix`, and `systems.nix` under [`hosts/rflxn-desktop`](./hosts/rflxn-desktop).

### `rflxn-asahi`

- Apple Silicon `aarch64-linux` laptop using the `nixos-apple-silicon` module.
- Uses Hyprland on the built-in `eDP-1` display, including touchpad gestures and a `60 Hz`/`120 Hz` monitor toggle.
- Uses systemd-boot with five retained configurations, Btrfs impermanence, NetworkManager Wi-Fi, zram, and an enabled stateful firewall.
- Includes Apple peripheral firmware, aarch64 Widevine support, Syncthing, and Tailscale.
- The specialized composition is kept mainly in [`hosts/rflxn-asahi/configuration.nix`](./hosts/rflxn-asahi/configuration.nix).

### `rflxn-server`

- Headless `x86_64-linux` server using systemd-boot and Btrfs impermanence.
- Runs Docker, Cloudflare DDNS, SSH, Samba, Deluge, Syncthing, Tailscale, nginx reverse proxies, JetBrains Remote, and VS Code Server.
- Acts as the XivMitm gateway for the desktop and as the central Syncthing peer for the other hosts.
- The service-oriented composition is in [`hosts/rflxn-server/configuration.nix`](./hosts/rflxn-server/configuration.nix).

## Build Requirements

### Common requirements

- Nix must have the `nix-command` and `flakes` experimental features enabled.
- The checked-in `hardware-configuration.nix` files and filesystem UUIDs are machine-specific. Regenerate or update them before installing on different hardware.
- Impermanence expects Btrfs subvolumes named `@root`, `@root-blank`, `@nix`, and `@persist`. The server mounts its persistence filesystem separately.
- All hosts expect the user password hash at `/persist/secrets/rflxn.hashedPassword`. The desktop also uses it for the root account.

Create the shared password secret without committing it:

```bash
sudo install -d -m 0700 /persist/secrets
mkpasswd -m sha-512 | sudo tee /persist/secrets/rflxn.hashedPassword >/dev/null
sudo chmod 0600 /persist/secrets/rflxn.hashedPassword
```

### `rflxn-desktop`

The desktop requires the common password secret and its machine-specific storage layout. Its XivMitm route also assumes gateway `192.168.100.100` on interface `eno1`.

```bash
# Build only
nix build .#nixosConfigurations.rflxn-desktop.config.system.build.toplevel

# Build and activate
sudo nixos-rebuild switch --flake .#rflxn-desktop
```

### `rflxn-asahi`

The Asahi host requires device-specific, non-redistributable Apple firmware at:

```text
hosts/rflxn-asahi/firmware/firmware.cpio
```

The file can be copied from the machine's EFI system partition after the Asahi installer has generated it:

```bash
install -m 0600 /boot/vendorfw/firmware.cpio \
  hosts/rflxn-asahi/firmware/firmware.cpio
```

The firmware directory is intentionally ignored by Git. Use an explicit `path:` flake reference so Nix includes the ignored firmware without moving `.git` or committing proprietary files:

```bash
# Build only
nix build 'path:.#nixosConfigurations.rflxn-asahi.config.system.build.toplevel'

# Build and activate
sudo nixos-rebuild switch --flake 'path:.#rflxn-asahi'
```

Firmware is device-specific. Replace `firmware.cpio` with the target Mac's copy before building for another Apple Silicon machine.

### `rflxn-server`

In addition to the common password hash, the server expects these runtime secrets:

| Path | Purpose |
| --- | --- |
| `/persist/secrets/ddns.env` | Cloudflare DDNS environment file containing `API_KEY=...` |
| `/persist/secrets/deluge.auth` | Deluge daemon authentication file |
| `/persist/secrets/deluge-web.auth` | JSON object containing `pwd_salt` and `pwd_sha1` |

The configured XivMitm gateway assumes interface `enp5s0` and desktop client `192.168.100.101/32`. Address assignment is managed outside this repository.

```bash
# Build only
nix build .#nixosConfigurations.rflxn-server.config.system.build.toplevel

# Build and activate
sudo nixos-rebuild switch --flake .#rflxn-server
```

## Module API

See [`API.md`](./API.md) for the exported `modules.system`, `modules.hardware`, `modules.desktop`, `modules.programs`, and `modules.services` API, including function arguments, defaults, required `specialArgs`, and known constraints.
