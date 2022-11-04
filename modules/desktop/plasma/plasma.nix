{ config, lib, pkgs, ... }:

{

    services = {
        xserver = {
            enable = true;
            desktopManager = {
                plasma5 = {
                    enable = true;
                };
            };
            autorun = true;
            videoDrivers = ["nvidia"];
        };
    };
}