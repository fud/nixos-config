{ pkgs, ... }:

{
  imports =
    [
      ../../modules/desktop/bspwm/home.nix
      #../../modules/desktop/hyprland/home.nix  # Window Manager
    ];

  home = {                                # Specific packages for desktop
    packages = with pkgs; [
      # Applications
      handbrake         # Encoder
      mkvtoolnix        # Matroska Tools
      plex-media-player # Media Player
    ];
  };

}