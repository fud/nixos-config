#  Specific system configuration settings for desktop
#

{ pkgs, lib, user, ... }:

{
  imports = [ (import ./hardware-configuration.nix) ]
    ++ (import ../../modules/desktop/virtualisation);

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "pci=noats" "amd_iommu=on" "iommu=pt" ];
    supportedFilesystems = [ "zfs" ];
    loader = {
      systemd-boot = { enable = true; };
      efi = { canTouchEfiVariables = true; };
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        mirroredBoots = [{
          devices = [ "/dev/disk/by-uuid/2216-6C13" ];
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
      bridges = { "br0" = { interfaces = [ "eno1" ]; }; };
    };
  };

  environment = { # Packages installed system wide
    systemPackages = with pkgs;
      [ # This is because some options need to be configured.
        x11vnc
      ];
  };
}