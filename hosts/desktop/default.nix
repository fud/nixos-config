#  Specific system configuration settings for desktop
#

{ pkgs, lib, user, config, ... }:

{
  imports = [(import ./hardware-configuration.nix)] ++
    [(import ./zfs.nix)] ++
    [(import ../../modules/desktop/bspwm/bspwm.nix)] ++
    (import ../../modules/desktop/virtualisation);

  networking = {
    hostName = "acrux";
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
