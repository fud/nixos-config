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

As found from [OpenZFS Mirroring](https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/Root%20on%20ZFS/1-preparation.html). See for better explanations.

su to root

```
sudo -u root bash
```

Get the devices by id

```
ls -la /dev/disk/by-id
```

Declare the disk array

```
DISK='/dev/disk/by-id/ata-FOO /dev/disk/by-id/nvme-BAR'
```

Set the swap size

```
INST_PARTSIZE_SWAP=32
```

Partition the disks

```
for i in ${DISK}; do

sgdisk --zap-all $i

sgdisk -n1:1M:+1G -t1:EF00 $i

sgdisk -n2:0:+4G -t2:BE00 $i

test -z $INST_PARTSIZE_SWAP || sgdisk -n4:0:+${INST_PARTSIZE_SWAP}G -t4:8200 $i

if test -z $INST_PARTSIZE_RPOOL; then
    sgdisk -n3:0:0   -t3:BF00 $i
else
    sgdisk -n3:0:+${INST_PARTSIZE_RPOOL}G -t3:BF00 $i
fi

sgdisk -a1 -n5:24K:+1000K -t5:EF02 $i
done
```

Create the `bool` pool

```
zpool create \
    -o compatibility=grub2 \
    -o ashift=12 \
    -o autotrim=on \
    -O acltype=posixacl \
    -O canmount=off \
    -O compression=lz4 \
    -O devices=off \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O mountpoint=/boot \
    -R /mnt \
    bpool \
    mirror \
    $(for i in ${DISK}; do
       printf "$i-part2 ";
      done)
```

Create the `root` pool.

```
zpool create \
    -o ashift=12 \
    -o autotrim=on \
    -R /mnt \
    -O acltype=posixacl \
    -O canmount=off \
    -O compression=zstd \
    -O dnodesize=auto \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O mountpoint=/ \
    rpool \
    mirror \
   $(for i in ${DISK}; do
      printf "$i-part3 ";
     done)
```

Create the root system container

```
zfs create \
 -o canmount=off \
 -o mountpoint=none \
 rpool/nixos
```

Create the system datasets

```
zfs create -o canmount=on -o mountpoint=/     rpool/nixos/root
zfs create -o canmount=on -o mountpoint=/home rpool/nixos/home
zfs create -o canmount=off -o mountpoint=/var  rpool/nixos/var
zfs create -o canmount=on  rpool/nixos/var/lib
zfs create -o canmount=on  rpool/nixos/var/log
```

Create the boot datasets

```
zfs create -o canmount=off -o mountpoint=none bpool/nixos
zfs create -o canmount=on -o mountpoint=/boot bpool/nixos/root
```

Format and mount ESP

```
for i in ${DISK}; do
 mkfs.vfat -n EFI ${i}-part1
 mkdir -p /mnt/boot/efis/${i##*/}-part1
 mount -t vfat ${i}-part1 /mnt/boot/efis/${i##*/}-part1
done

mkdir -p /mnt/boot/efi
mount -t vfat $(echo $DISK | cut -f1 -d\ )-part1 /mnt/boot/efi
```

### Partitioning the Data drives

Get the devices by id

```
ls -la /dev/disk/by-id
```

List partition types

```
 sgdisk --list-types
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
zpool create -O mountpoint=none -O atime=off -o ashift=12 -O acltype=posixacl -O xattr=sa -O compression=lz4 zpool mirror $DISK1-part1 $DISK2-part1
```

### ZFS Data Drive FS

```
zfs create -o mountpoint=legacy zpool/virtual
zfs create -o mountpoint=legacy zpool/virtual/snapshots
zfs create -o mountpoint=legacy zpool/virtual/images
zfs create -o mountpoint=legacy zpool/virtual/vms
zfs create -o mountpoint=legacy zpool/virtual/vms/windows10
zfs create -o mountpoint=legacy zpool/virtual/vms/windows11
```

### System config

Disable the stale cache

```
mkdir -p /mnt/etc/zfs/
rm -f /mnt/etc/zfs/zpool.cache
touch /mnt/etc/zfs/zpool.cache
chmod a-w /mnt/etc/zfs/zpool.cache
chattr +i /mnt/etc/zfs/zpool.cache
```

### Generate

```
nixos-generate-config --root /mnt
nix-env -iA nixos.git
git clone https://github.com/fud/nixos-config /mnt/etc/nixos/fud
```

### Install

In these commands

- Move into cloned repository
  - in this example /mnt/etc/nixos/<name>
- Available hosts:
  - desktop

```
cd /mnt/etc/nixos/<name>
nixos-install --flake .#<host>
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
