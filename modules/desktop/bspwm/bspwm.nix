{ config, lib, pkgs, ... }:

{
  programs.dconf.enable = true;

  services = {
    xserver = {
      enable = true;

      layout = "us";
      libinput.enable = true;

      displayManager = {
        lightdm = {
          enable = true;
          background = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
          greeters = {
            gtk = {
              theme = {
                name = "Dracula";
                package = pkgs.dracula-theme;
              };
              cursorTheme = {
                name = "Dracula-cursors";
                package = pkgs.dracula-theme;
                size = 16;
              };
            };
          };
        };
        defaultSession = "none+bspwm";
      };

      windowManager= {
        bspwm = {
          enable = true;
        };
      };
    };
  };

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    xclip
    xorg.xev
    xorg.xkill
    xorg.xrandr
    xterm
    #alacritty
    #sxhkd
  ];
}