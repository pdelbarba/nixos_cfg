{ inputs, outputs, lib, config, pkgs, ... }: {
  # You can import other NixOS modules here
  imports = [
    inputs.hardware.nixosModules.common-cpu-amd
    #inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-ssd

    ../common
    
    #./users.nix

    ./hardware-configuration.nix
  ];

  # Aux drive mounts

  boot.supportedFilesystems = [ "ntfs" "zfs" ];
  boot.zfs.extraPools = [ "photo-pool" "games" ];
  services.zfs.autoScrub.enable = true;
  boot.zfs.forceImportRoot = false;
  services.zfs.trim.enable = true;
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;  

  fileSystems."/disks/f" = {
    device = "/dev/disk/by-uuid/4EF4DC53F4DC3F41";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1001" ];
  };

  fileSystems."/disks/n" = {
    device = "dev/disk/by-uuid/DA22598B22596E0F";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1001" ];
  };

  fileSystems."/disks/c" = {
    device = "/dev/disk/by-uuid/8476C3C676C3B6E8";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1001" ];
  };

  fileSystems."/disks/net_archive" = {
    device = "patrick@tron:/raidpool/encrypted/net_archive";
    fsType = "sshfs";
    options = [ "noatime" "default_permissions" "allow_other" "uid=1001" "gid=100" "idmap=user" "identityfile=/home/patrick/.ssh/id_ed25519" ];
  };

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
      inputs.private-fonts.overlays.default
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

  services.printing.enable = true;

  hardware.printers = {
    ensurePrinters = [
      {
        name = "Brother-HL-L2300D";
        location = "Desk";
        deviceUri = "usb://Brother/HL-L2300D%20series?serial=U63878M7N266193";
        model = "drv:///sample.drv/generic.ppd";
      }
    ];
  };

  
  sound.enable = true;

  environment.variables = rec { # rec statement allows list elements to ref each other
    EDITOR = "hx";
  };
  
  networking = {
    firewall = {
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ ];
    };
    hostName = "solaros";
    hostId = "007f0200";
    extraHosts = ''
      10.1.1.248    tron.slow 
      169.254.0.2   tron
      169.254.0.2   gitea.tron
      169.254.0.2   photos.tron
      169.254.0.2   frig.tron
      169.254.0.2   jelly.tron
      169.254.0.2   cloud.tron
    '';

    interfaces = {
      enp5s0.ipv4 = {
        addresses = [{
          address = "169.254.0.3";
          prefixLength = 24;
        }];
        
        routes = [{
          address = "169.254.0.2";
          prefixLength = 32;
          via = "169.254.0.3";
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
    gitui

    # hardware dev/drivers stuff
    rtl-sdr
    
    # cmd utils
    tree
    fish
    tmux
    ripgrep
    fzf
    rm-improved
    kitty
    zip
    unzip
    nnn
    eza
    usbutils
    pciutils
    zfs
    sshfs
    borgbackup
    lsof
    nvd
    dig
    jq

    # wayland utils
    grim
    wl-clipboard
    swww

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

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      open-sans
      dejavu_fonts
      eb-garamond
      berkeley-mono
      (nerdfonts.override { fonts = [ "Hack" "FiraCode" "DroidSansMono" ]; })
    ];
    fontconfig = {
      defaultFonts = {
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
        monospace = [ "Hack" "Noto Sans Mono" ];
      };
    };
  };


  hardware.rtl-sdr.enable = true;
  

  services = {
    udev.packages = [ pkgs.rtl-sdr ];
    udev.extraRules = ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", MODE="0666"
      SUBSYSTEM=="usb_device", ATTRS{idVendor}=="0403", MODE="0666"
    '';


    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };

    flatpak.enable = true;
  };
  
  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  # TODO: move to another file under common
  users.users = {
    patrick = {
      initialPassword = "a4b3c2d1";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHx5z0WQb4t6Q0P98XZhw+0DC9X7p+m4qNJUXhmbXCK4 patrick@phone"
      ];
      extraGroups = [ "wheel" "audio" "plugdev" ];
    };
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  #needed for swaylock to work
  security.pam.services.swaylock = {};

  programs.hyprland.enable = true;
  services.xserver = {
    enable = true;
    videoDrivers = ["nvidia"];
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    layout = "us";
    xkbVariant = "dvorak";
  };

  environment.variables = rec {
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
  };
  
  hardware.nvidia = {
    powerManagement.enable = true;
    #powerManagement.finegrained = false; #Turing and later
    modesetting.enable = true;
    nvidiaSettings = true;
    #open = true;
  };
  
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
