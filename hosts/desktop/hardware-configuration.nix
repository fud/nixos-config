{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ahci" "usbhid" "sd_mod" "amdgpu" "vfio-pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "zroot/root";
    fsType = "zfs";
  };

  fileSystems."/nix" = {
    device = "zroot/root/nix";
    fsType = "zfs";
  };

  fileSystems."/nix/store" = {
    device = "/nix/store";
    fsType = "none";
    options = [ "bind" ];
  };

  fileSystems."/home" = {
    device = "zroot/root/home";
    fsType = "zfs";
  };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/67CA-BF15";
      fsType = "vfat";
    };

  fileSystems."/boot-fallback" =
    { device = "/dev/disk/by-uuid/6815-7BDE";
      fsType = "vfat";
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

}
