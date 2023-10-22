{ inputs, outputs, lib, config, pkgs, ... }: {
  # You can import other NixOS modules here
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-ssd

    ../common
    
    #./users.nix

    ./hardware-configuration.nix
  ];

  # Aux drive mounts

  boot.supportedFilesystems = [ "ntfs" "zfs" ];
  #boot.zfs.extraPools = [ "photo-pool" "games" ];
  services.zfs.autoScrub.enable = true;
  boot.zfs.forceImportRoot = false;
  services.zfs.trim.enable = true;
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;  

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/6e14be55-2aac-41fd-a1eb-6dbd4a3db171";
      preLVM = true;
    };
  }; 

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
 
  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  time.timeZone = "America/Denver";

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

  };


  environment.variables = rec { # rec statement allows list elements to ref each other
    EDITOR = "hx";
  };
  
  networking = {
    firewall = {
      allowedTCPPorts = [ 22 80 443 ];
      allowedUDPPorts = [ ];
    };
    hostName = "tron";
    hostId = "00a389b3";
    extraHosts = ''
    '';

    interfaces = {
      enp1s0f1.ipv4 = {
        addresses = [{
          address = "169.254.0.2";
          prefixLength = 24;
        }];
      };
    };
  };
  
  environment.systemPackages = with pkgs; [
    wget
    curl

    # dev stuff
    git
    tig
    
    # cmd utils
    tree
    fish
    tmux
    ripgrep
    fzf
    rm-improved
    zip
    nnn
    eza
    usbutils
    pciutils
    zfs
    borgbackup

    # top of the morning
    htop
    iotop
    gtop
    iftop

    # nix related utils
    nix-output-monitor

    ((vim_configurable.override {  }).customize{
      name = "vim";
      vimrcConfig.packages.myplugins = with pkgs.vimPlugins; {
        start = [ vim-nix vim-lastplace ];
        opt = [];
      };
      vimrcConfig.customRC = ''
        syntax on
        set hlsearch
        set showcmd
        set showmode
        set softtabstop=2
        set noshiftround
        set ruler
        set ignorecase
        set tabstop=2
        set shiftwidth=2
        set expandtab
        set number
      '';
    }
  )
  ];


  services = {
    flatpak.enable = true;
  };

  # TODO: move to another file under common
  users.users = {
    patrick = {
      initialPassword = "a4b3c2d1";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAaRp0/N4pol7BxSkK0W+ofqmUogRQ/vvrDTipqo7oIb patrick@solaros"
      ];
      extraGroups = [ "wheel" ];
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}