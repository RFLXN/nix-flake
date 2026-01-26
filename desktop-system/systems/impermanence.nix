{ lib, ... }: {
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir /btrfs_tmp
    mount /dev/disk/by-uuid/29f7cd79-b677-4d59-a8f1-db6a9cbdc69f /btrfs_tmp
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

    for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
        delete_subvolume_recursively "$i"
    done

    btrfs subvolume snapshot /btrfs_tmp/@root-blank /btrfs_tmp/@root
    umount /btrfs_tmp
  '';

  environment.persistence."/persist" = {
    hideMounts = true;

    directories = [
      "/home"
      "/var/log"
      "/var/lib/docker"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      "/var/lib/tailscale"  # for persist tailscale ip
    ];

    files = [
      "/etc/machine-id"
    ];
  };
}