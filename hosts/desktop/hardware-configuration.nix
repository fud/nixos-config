{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ahci" "usbhid" "sd_mod" "amdgpu" "vfio-pci" "uas"];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "rpool/nixos/root";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/home" =
    { device = "rpool/nixos/home";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/var/lib" =
    { device = "rpool/nixos/var/lib";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/var/log" =
    { device = "rpool/nixos/var/log";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/boot" =
    { device = "bpool/nixos/root";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/boot/efis/ata-Samsung_SSD_850_EVO_500GB_S21GNXAG805611X-part1" =
    { device = "/dev/disk/by-uuid/E10C-3A6E";
      fsType = "vfat";
    };

  fileSystems."/boot/efis/ata-Samsung_SSD_860_EVO_500GB_S4BENS0N804509D-part1" =
    { device = "/dev/disk/by-uuid/E10C-D94B";
      fsType = "vfat";
    };

  fileSystems."/boot/efi" =
    { device = "/boot/efis/ata-Samsung_SSD_850_EVO_500GB_S21GNXAG805611X-part1";
      fsType = "none";
      options = [ "bind" ];
    };

  fileSystems."/var/lib/libvirt/images" = {
    device = "zpool/virtual/images";
    fsType = "zfs";
  };

  fileSystems."/var/lib/libvirt/snapshots" = {
    device = "zpool/virtual/snapshots";
    fsType = "zfs";
  };

  fileSystems."/var/lib/libvirt/vms/macosx" = {
    device = "zpool/virtual/vms/macosx";
    fsType = "zfs";
  };

  fileSystems."/var/lib/libvirt/vms/windows10" = {
    device = "zpool/virtual/vms/windows10";
    fsType = "zfs";
  };

  fileSystems."/var/lib/libvirt/vms/windows11" = {
    device = "zpool/virtual/vms/windows11";
    fsType = "zfs";
  };

   swapDevices = [ ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
