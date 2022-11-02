#
# XRdp
#

{ config, pkgs, user, ... }:

{
  services.xrdp = {
    enable = true;
    defaultWindowManager = "${pkgs.bspwm}/bin/bspwm";
  };

  networking.firewall.allowedTCPPorts = [ 3389 ];
}
