#
# Qemu/KVM with virt-manager
#

{ config, pkgs, user, ... }:

{
  users.groups.a.members = [ "root" "${user}" ];

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        ovmf = {
          enable = true;
        };
        runAsRoot = false;
      };
      onBoot = "ignore";
      onShutdown = "shutdown";
    };
    spiceUSBRedirection.enable = true;        # USB passthrough
  };

  environment = {
    systemPackages = with pkgs; [
      linuxPackages_5_10.vendor-reset
      virt-manager
      virt-viewer
      qemu
      OVMF
      gvfs                                    # Used for shared folders between linux and windows
    ];
  };

  services = {                                # Enable file sharing between OS
    gvfs.enable = true;
  };

  boot.kernelParams = [ "pci=noats" "amd_iommu=on" "iommu=pt" ];

  # boot.initrd.preDeviceCommands = ''
  #       DEVS="06:00.0 06:00.1"
  #       for DEV in $DEVS; do
  #           echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
  #       done
  #       modprobe -i vfio-pci
  # '';
}