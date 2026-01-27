# Context: SDDM Dual Monitor Configuration - Wayland Migration

## Problem
- Dual monitor setup with vertical sub monitor
- Main monitor: DP-3 (1920x1080 @ 200Hz, primary)
- Sub monitor: HDMI-A-1 (1080x1920, rotated left for vertical use)
- Works well in KDE Plasma desktop environment
- SDDM login screen shows same display on both monitors (mirrored)
- Goal: Match SDDM display configuration with Plasma desktop settings

## Root Cause Discovery
- Was using Wayland sessions by default but configured X11-specific settings
- X11 xrandr commands don't work on Wayland SDDM
- Different sessions (X11 vs Wayland) maintain separate desktop settings
- KDE Plasma 6 defaults to Wayland

## Solution: Declarative Wayland Configuration

### Root Issue
The initial Wayland migration enabled SDDM Wayland support but didn't deploy the display configuration to SDDM's config directory (`/var/lib/sddm/.config/`), causing SDDM to use default mirrored display settings.

### Files Changed

1. **Created** `/home/rflxn/nix/desktop-system/services/kwinoutputconfig.json`:
   - Stores the dual monitor configuration declaratively in the Nix config
   - Contains display settings for DP-3 (1920x1080@200Hz) and HDMI-A-1 (1080x1920@60Hz, Rotated90)

2. **Modified** `/home/rflxn/nix/desktop-system/services/desktop-environment.nix`:

```nix
{ pkgs, ... }: {
  # Enable X server (still needed for XWayland compatibility)
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Enable KDE Plasma 6 (uses Wayland by default)
  services.desktopManager.plasma6.enable = true;

  # Configure SDDM with Wayland
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;  # Enable Wayland for SDDM
  };

  # Deploy SDDM display configuration declaratively
  systemd.tmpfiles.rules = [
    # Create SDDM config directory
    "d /var/lib/sddm/.config 0755 sddm sddm -"
    # Copy KWin output configuration for dual monitor setup
    "C /var/lib/sddm/.config/kwinoutputconfig.json 0644 sddm sddm - ${./kwinoutputconfig.json}"
  ];

  security.rtkit.enable = true;
}
```

### How It Works
- `systemd-tmpfiles` runs on boot and `nixos-rebuild switch`
- Automatically creates `/var/lib/sddm/.config/` with correct ownership
- Deploys `kwinoutputconfig.json` from Nix store to SDDM's config directory
- Fully declarative - no manual file management needed

**Nix Store Behavior:**
- `${./kwinoutputconfig.json}` copies the file to Nix store (e.g., `/nix/store/abc123...-kwinoutputconfig.json`)
- The systemd tmpfiles rule references the Nix store path, not the source directory
- Changes to source file only take effect after `nixos-rebuild switch`
- This ensures reproducibility and immutability

### Deployment
```bash
sudo nixos-rebuild switch
```

### Technical Details
- **Wayland SDDM** uses KWin as compositor
- **Display config location**: `/var/lib/sddm/.config/kwinoutputconfig.json`
- **Config format**: JSON array with "outputs" (display properties) and "setups" (layout/positioning)
- **SDDM config**: `/etc/sddm.conf` (NixOS-managed symlink to `/etc/static/sddm.conf`)

### Updating Display Configuration
If you change display settings in KDE:
1. Export config: `cat ~/.config/kwinoutputconfig.json > ~/nix/desktop-system/services/kwinoutputconfig.json`
2. Rebuild: `sudo nixos-rebuild switch`

**Reference:** [Arch Wiki - SDDM Match Plasma display configuration](https://wiki.archlinux.org/title/SDDM#Match_Plasma_display_configuration)
