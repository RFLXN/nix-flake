{
  rootUuid,
  persistPath ? null,
  directories ? [],
  files ? [],
  enableWipeRoot ? true,
}:
{ lib, pkgs, utils, impermanence, defaultPersistPath ? null, ... }:
let
  rootDevice = "/dev/disk/by-uuid/${rootUuid}";
  rootDeviceUnit = "${utils.escapeSystemdPath rootDevice}.device";
  persistencePath = if persistPath != null then persistPath else defaultPersistPath;
in
{
  imports = [ impermanence.nixosModules.impermanence ];

  boot.initrd.systemd.extraBin = lib.optionalAttrs enableWipeRoot {
    btrfs = "${pkgs.btrfs-progs}/bin/btrfs";
    cut = "${pkgs.coreutils}/bin/cut";
    date = "${pkgs.coreutils}/bin/date";
    find = "${pkgs.findutils}/bin/find";
    mkdir = "${pkgs.coreutils}/bin/mkdir";
    mv = "${pkgs.coreutils}/bin/mv";
    stat = "${pkgs.coreutils}/bin/stat";
  };

  boot.initrd.systemd.services = lib.optionalAttrs enableWipeRoot {
    wipe-root = {
      description = "Replace Btrfs root subvolume";
      wantedBy = [ "sysroot.mount" ];
      wants = [ rootDeviceUnit ];
      after = [ rootDeviceUnit ];
      before = [
        "sysroot.mount"
        "shutdown.target"
      ];
      conflicts = [ "shutdown.target" ];
      unitConfig.DefaultDependencies = false;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        set -euo pipefail

        log_file=

        log() {
          local line
          line="$(date -Is) wipe-root: $*"
          echo "$line"
          if [[ -n "$log_file" ]]; then
            printf '%s\n' "$line" >> "$log_file"
          fi
        }

        on_error() {
          local status=$?
          log "failed at line $1 with status $status"
          exit "$status"
        }

        cleanup() {
          local status=$?
          umount /btrfs_tmp >/dev/null 2>&1 || true
          exit "$status"
        }

        trap 'on_error $LINENO' ERR
        trap cleanup EXIT

        mkdir -p /btrfs_tmp

        log "mounting ${rootDevice} at Btrfs top level"
        mount -o subvolid=5 ${rootDevice} /btrfs_tmp

        if [[ -d /btrfs_tmp/@persist ]]; then
          mkdir -p /btrfs_tmp/@persist/log
          log_file=/btrfs_tmp/@persist/log/wipe-root.log
          log "writing persistent log to /persist/log/wipe-root.log"
        else
          log "persistent @persist subvolume not found; only initrd journal will contain wipe-root logs"
        fi

        delete_subvolume_recursively() {
          local subvolume="$1"
          local children child
          children="$(btrfs subvolume list -o "$subvolume" | cut -f 9- -d ' ')"
          while IFS= read -r child; do
            [[ -z "$child" ]] && continue
            delete_subvolume_recursively "/btrfs_tmp/$child"
          done <<< "$children"

          log "deleting old subvolume $subvolume"
          btrfs subvolume delete "$subvolume"
        }

        if [[ ! -d /btrfs_tmp/@root-blank ]]; then
          log "missing @root-blank; leaving existing @root in place"
          exit 0
        fi

        if [[ -e /btrfs_tmp/@root-new ]]; then
          log "removing stale @root-new"
          if ! delete_subvolume_recursively /btrfs_tmp/@root-new; then
            log "failed to remove stale @root-new; leaving existing @root in place"
            exit 0
          fi
        fi

        log "creating temporary @root-new snapshot from @root-blank"
        if ! btrfs subvolume snapshot /btrfs_tmp/@root-blank /btrfs_tmp/@root-new; then
          log "failed to create @root-new; leaving existing @root in place"
          exit 0
        fi

        old_root=
        if [[ -e /btrfs_tmp/@root ]]; then
          mkdir -p /btrfs_tmp/old_roots
          timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/@root)" "+%Y-%m-%-d_%H:%M:%S")
          old_root="/btrfs_tmp/old_roots/$timestamp"
          counter=1
          while [[ -e "$old_root" ]]; do
            old_root="/btrfs_tmp/old_roots/$timestamp-$counter"
            counter=$((counter + 1))
          done
          log "moving current @root to $old_root"
          if ! mv /btrfs_tmp/@root "$old_root"; then
            log "failed to move current @root; removing @root-new and leaving existing @root in place"
            btrfs subvolume delete /btrfs_tmp/@root-new >/dev/null 2>&1 || true
            exit 0
          fi
        else
          log "no existing @root found"
        fi

        log "moving @root-new to @root"
        if ! mv /btrfs_tmp/@root-new /btrfs_tmp/@root; then
          log "failed to move @root-new to @root"
          if [[ -n "$old_root" && -e "$old_root" && ! -e /btrfs_tmp/@root ]]; then
            log "attempting to restore previous @root"
            mv "$old_root" /btrfs_tmp/@root || true
          fi
          exit 1
        fi
        log "fresh @root snapshot installed"

        if [[ -d /btrfs_tmp/old_roots ]]; then
          cleanup_status=0
          old_roots="$(find /btrfs_tmp/old_roots -mindepth 1 -maxdepth 1 -type d -mtime +30)"
          while IFS= read -r old_root; do
            [[ -z "$old_root" ]] && continue
            if ! delete_subvolume_recursively "$old_root"; then
              cleanup_status=1
              log "failed to delete $old_root; continuing boot because fresh @root already exists"
            fi
          done <<< "$old_roots"
          if [[ "$cleanup_status" -eq 0 ]]; then
            log "old root cleanup completed"
          else
            log "old root cleanup completed with errors"
          fi
        fi
      '';
    };
  };

  environment.persistence.${persistencePath} = {
    hideMounts = true;
    directories = [
      "/home"
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
    ] ++ directories;
    files = [ "/etc/machine-id" ] ++ files;
  };
}
