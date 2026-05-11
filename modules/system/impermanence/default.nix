{ rootUuid, persistPath ? null, directories ? [], files ? [] }:
{ lib, impermanence, defaultPersistPath ? null, ... }:
let
  path = if persistPath != null then persistPath else defaultPersistPath;
in
{
  imports = [ impermanence.nixosModules.impermanence ];

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir -p /btrfs_tmp
    mount -o subvolid=5 /dev/disk/by-uuid/${rootUuid} /btrfs_tmp
    if [[ -e /btrfs_tmp/@root ]]; then
      mkdir -p /btrfs_tmp/old_roots
      timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/@root)" "+%Y-%m-%-d_%H:%M:%S")
      mv /btrfs_tmp/@root "/btrfs_tmp/old_roots/$timestamp"
    fi

    delete_subvolume_recursively() {
      IFS=$'\n'
      for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
        delete_subvolume_recursively "/btrfs_tmp/$i"
      done
      btrfs subvolume delete "$1"
    }

    if [[ -d /btrfs_tmp/old_roots ]]; then
      for i in $(find /btrfs_tmp/old_roots -mindepth 1 -maxdepth 1 -type d -mtime +30); do
        delete_subvolume_recursively "$i"
      done
    fi

    btrfs subvolume snapshot /btrfs_tmp/@root-blank /btrfs_tmp/@root
    umount /btrfs_tmp
  '';

  environment.persistence.${path} = {
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
