#
# XRdp
#

{ config, pkgs, user, ... }:

{
  services.xrdp = {
    enable = true;
    defaultWindowManager = "bspwm";
  };

  networking.firewall.allowedTCPPorts = [ 3389 ];
}
