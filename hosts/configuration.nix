{ config, lib, pkgs, inputs, user, location, ... }:

{
  imports = [ ];

  users.users.${user} = { # System User
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" "docker" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFANqxKsQzD00spT2M+Op7n8/8Bd+I9q6umyL7RuVWWx billsb@m1"
    ];
  };

  time.timeZone = "Australia/Brisbane";
  i18n = { defaultLocale = "en_US.UTF-8"; };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us"; # or us/azerty/etc
  };

  fonts.fonts = with pkgs; [
    carlito
    vegur
    source-code-pro
    jetbrains-mono
    font-awesome
    corefonts
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  environment = {
    variables = {
      TERMINAL = "alacritty";
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    systemPackages = with pkgs; [
      # Default packages install system-wide
      killall
      nano
      pciutils
      usbutils
      wget
    ];
  };

  # SSH: secure shell (remote connection to shell of server)
  # local: $ ssh <user>@<ip>
  # public:
  #   - port forward 22 TCP to server
  #   - in case you want to use the domain name insted of the ip:
  #       - for me, via cloudflare, create an A record with name "ssh" to the correct ip without proxy
  #   - connect via ssh <user>@<ip or ssh.domain>
  # generating a key:
  #   - $ ssh-keygen   |  ssh-copy-id <ip/domain>  |  ssh-add
  #   - if ssh-add does not work: $ eval `ssh-agent -s`
  # SFTP: secure file transfer protocol (send file to server)
  # connect: $ sftp <user>@<ip/domain>
  # commands:
  #   - lpwd & pwd = print (local) parent working directory
  #   - put/get <filename> = send or receive file

  services = {
    openssh = {
      enable = true;
      allowSFTP = true;
      forwardX11 = true;
    };
    ntp = { enable = true; };
  };

  nix = {
    settings = {
      # Optimise syslinks
      auto-optimise-store = true;
    };
    gc = { # Automatic garbage collection
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    registry.nixpkgs.flake = inputs.nixpkgs;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs          = true
      keep-derivations      = true
    '';
  };
  nixpkgs.config.allowUnfree = true; # Allow proprietary software.

  system = { # NixOS settings
    autoUpgrade = { # Allow auto update
      enable = true;
      channel = "https://nixos.org/channels/nixos-unstable";
    };
    stateVersion = "22.05";
  };
}
