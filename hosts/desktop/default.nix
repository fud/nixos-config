#  Specific system configuration settings for desktop
#

{ pkgs, lib, user, config, ... }:

{
  imports = [
    (import ./hardware-configuration.nix)
  ];
    #++ (import ../../modules/desktop/virtualisation);

  boot = {
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    kernelParams = [ "pci=noats" "amd_iommu=on" "iommu=pt" ];
    supportedFilesystems = [ "zfs" ];
    loader = {
      efi = { canTouchEfiVariables = true; };
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        mirroredBoots = [{
          devices = [ "/dev/disk/by-uuid/6815-7BDE" ];
          path = "/boot-fallback";
        }

          ];
      };
    };
  };

  networking = {
    hostName = "acrux";
    hostId = "41716712";
    useDHCP = false;
    interfaces = {
      eno1 = { useDHCP = true; };
      br0 = { useDHCP = true; };
    };
    bridges = {
        "br0" = {
            interfaces = [ "eno1" ];
        };
    };
  };

  environment = { # Packages installed system wide
    systemPackages = with pkgs;
      [ # This is because some options need to be configured.
        x11vnc
      ];
  };
}
