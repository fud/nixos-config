#
# XRdp
#

{ config, pkgs, user, ... }:

{
  services.xrdp = {
    enable = true;
    defaultWindowManager = "startplasma-x11";
  };

  networking.firewall.allowedTCPPorts = [ 3389 ];
}
