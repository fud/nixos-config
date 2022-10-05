# Brenton's NixOS & Nix-Darwin System Configuration Flake

# Table of Contents

- [NixOS installation](#nixos-installation)
  - Boot Drives
    - [Partitioning](#partitioning-the-boot-drives)
    - [ZPool](#zpool-boot)
    - [ZFS Layout](#zfs-boot-layout)
  - Data Drives
    - [Partitioning](#partitioning-the-data-drives)
  - [Generate](#generate)
  - [Install](#install)

## NixOS Installation

### Partitioning the boot drives

As found from [ZFS Mirroring](https://elis.nu/blog/2019/08/encrypted-zfs-mirror-with-mirrored-boot-on-nixos/). See for better explanations.

Get the devices by id

```
ls -la /dev/disk/by-id
```

Partition them.

```
DISK1=/dev/disk/by-id/ata-VENDOR-ID-OF-THE-FIRST-DRIVE
DISK2=/dev/disk/by-id/ata-VENDOR-ID-OF-THE-SECOND-DRIVE
sgdisk -n3:1M:+512M -t3:EF00 $DISK1
sgdisk -n2:0:+8G -t2:8200 $DISK1
sgdisk -n1:0:0 -t1:BF01 $DISK1
sfdisk --dump $DISK1 | sfdisk $DISK2
```

### Make Swap

mkswap -L $DISK1-part2
mkswap -L $DISK2-part2

### ZPool Boot

Root partition

```
zpool create -O mountpoint=none -O atime=off -o ashift=12 -O acltype=posixacl -O xattr=sa -O compression=lz4 zroot mirror $DISK1-part1 $DISK2-part1
```

### ZFS Boot Layout

```
zfs create -o mountpoint=legacy zroot/root      # For /
zfs create -o mountpoint=legacy zroot/root/home # For /home
zfs create -o mountpoint=legacy zroot/root/nix  # For /nix
```

### ESP Partitions Boot

```
mkfs.vfat $DISK1-part3
mkfs.vfat $DISK2-part3
```

### Mounting Boot

```
zpool import zroot
zfs load-key zroot

mount -t zfs zroot/root /mnt

# Create directories to mount file systems on
mkdir /mnt/{nix,home,boot,boot-fallback}

# Mount the rest of the ZFS file systems
mount -t zfs zroot/root/nix /mnt/nix
mount -t zfs zroot/root/home /mnt/home

# Mount both of the ESP's
mount $DISK1-part3 /mnt/boot
mount $DISK2-part3 /mnt/boot-fallback
```

### Partitioning the Data drives

Get the devices by id

```
ls -la /dev/disk/by-id
```

Partition them.

```
DISK1=/dev/disk/by-id/ata-VENDOR-ID-OF-THE-FIRST-DRIVE
DISK2=/dev/disk/by-id/ata-VENDOR-ID-OF-THE-SECOND-DRIVE
sgdisk -n1:0:0 -t1:BF01 $DISK1
sfdisk --dump $DISK1 | sfdisk $DISK2
```

# ZFS Data drives

```
# zpool create -O mountpoint=none -O atime=off -o ashift=12 -O acltype=posixacl -O xattr=sa -O compression=lz4 zpool mirror $DISK1-part1 $DISK2-part1
```

### ZFS Data Drive FS

```
# zfs create -o mountpoint=legacy zpool/virtual/snapshots
# zfs create -o mountpoint=legacy zpool/virtual/images
# zfs create -o mountpoint=legacy zpool/virtual/vms/windows10
# zfs create -o mountpoint=legacy zpool/virtual/vms/windows11
# zfs create -o mountpoint=legacy zpool/virtual/vms/macosx
```

### Generate

```
# swapon $DISK1-part2
# nixos-generate-config --root /mnt
# nix-env -iA nixos.git
#  git clone https://github.com/fud/nixos-config /mnt/etc/nixos/fud
```

### Install

In these commands

- Move into cloned repository
  - in this example /mnt/etc/nixos/<name>
- Available hosts:
  - desktop

```
# cd /mnt/etc/nixos/<name>
# nixos-install --flake .#<host>
```

### Finalisation

1. Set a root password after installation is done
2. Reboot without livecd
3. Login
   i. If initialPassword is not set use TTY:

   - `Ctrl - Alt - F1`
   - login as root
   - `# passwd <user>`
   - Ctrl - Alt - F7
   - login as user

4. Optional:

   - `$ sudo mv <location of cloned directory> <prefered location>`
   - `$ sudo chown -R <user>:users <new directory>`
   - `$ sudo rm /etc/nixos/configuration.nix`
   - or just clone flake again do apply same changes.

5. Rebuilds:
   - `<flakelocation>$ sudo nixos-rebuild switch --flake .#<host>`

# Thanks

This is based on Matthias Benaets config and videos.

- [Matthias Benaets Config](https://github.com/MatthiasBenaets/nixos-config)

ZFS Setup is based on

- [ZFS & Boot Mirroring](https://elis.nu/blog/2019/08/encrypted-zfs-mirror-with-mirrored-boot-on-nixos/)
