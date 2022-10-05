#
# XRdp
#

{ config, pkgs, user, ... }:

{

  service.xrdp = {
    enable = true;
    defaultWindowManager = "startplasma-x11";
  };

  networking.firewall.allowedTCPPorts = [ 3389 ];
}
