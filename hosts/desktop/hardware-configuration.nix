{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ahci" "usbhid" "sd_mod" "amdgpu" "vfio-pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  boot.zfs.devNodes = "/dev/disk/by-path";

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
    { device = "/dev/disk/by-uuid/ECBE-4CCA";
      fsType = "vfat";
    };

  fileSystems."/boot-fallback" =
    { device = "/dev/disk/by-uuid/ED05-2808";
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

   swapDevices =
    [ { device = "/dev/disk/by-uuid/2e28e18b-a24e-419f-b988-d0e7000da491"; }
    ];

}
