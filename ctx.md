# AMD Ryzen UCLK/FCLK Monitoring on Linux

## Problem
Need to check UCLK (Unified Memory Controller Clock) and FCLK (Fabric Clock) on AMD Ryzen 7 9700X (Zen 5) running NixOS, similar to HWiNFO64 on Windows.

## What Doesn't Work
- **`dmidecode --type 17`**: Only shows static memory specs from SMBIOS (Speed: 5600 MT/s, Configured: 6000 MT/s), not runtime clocks
- **`lm-sensors`**: Shows temperatures and GPU clocks, but doesn't expose CPU memory controller clocks (UCLK/FCLK)
- **zenmonitor**: Not updated for Zen 5, won't work

## Current Configuration
System: AMD Ryzen 7 9700X, 2x16GB DDR5-6000, NixOS with kernel 6.12.67

Already configured in `/home/rflxn/nix/desktop-system/systems/amd.nix`:
```nix
{ ... }: {
  hardware.amdgpu.overdrive.enable = true;
  hardware.cpu.amd.ryzen-smu.enable = true;
}
```

## Current Status
- `ryzen-smu` module is enabled in config but not yet loaded (needs reboot)
- Module exists in NixOS packages for kernel 6.12

## After Reboot - How to Check UCLK/FCLK

### 1. Verify module is loaded:
```bash
lsmod | grep ryzen_smu
ls /sys/kernel/ryzen_smu_drv/
```

### 2. Install ryzenadj (if not already installed):
Add to `/home/rflxn/nix/desktop-system/packages/syspkgs.nix`:
```nix
ryzenadj  # AMD Ryzen power management and monitoring tool
```

Then rebuild: `sudo nixos-rebuild switch`

### 3. Read UCLK/FCLK:
```bash
sudo ryzenadj --info
```

This should show:
- **FCLK** (Infinity Fabric Clock)
- **UCLK** (Memory Controller Clock)
- **MCLK** (Memory Clock)

Expected values for DDR5-6000:
- MCLK: ~3000 MHz (6000 MT/s ÷ 2)
- UCLK: ~3000 MHz (1:1 ratio with MCLK)
- FCLK: ~2000-2400 MHz (depending on BIOS settings)

### Alternative: Check via sysfs
After module loads, explore:
```bash
find /sys/kernel/ryzen_smu_drv -type f
cat /sys/kernel/ryzen_smu_drv/pm_table
```

## Memory Configuration Summary (from dmidecode)
- 2x 16GB DDR5 modules (JUHOR JHE6800U3416JGRGB)
- Slots: DIMM 1 Channel A, DIMM 1 Channel B
- Speed: 5600 MT/s (JEDEC spec)
- Configured Speed: 6000 MT/s (XMP/EXPO profile)
- Voltage: 1.1V
- Dual channel configuration
