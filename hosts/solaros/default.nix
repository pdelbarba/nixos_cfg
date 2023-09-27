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

  services.printing.enable = true;
  
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
    extraHosts = ''
      10.1.1.248 tron
      10.1.1.248 gitea.tron
      10.1.1.248 photos.tron
      10.1.1.248 frig.tron
    '';
  };
  
  environment.systemPackages = with pkgs; [
    wget
    curl

    # dev stuff
    git
    tig
    gitui

    # cmd utils
    tree
    fish
    tmux
    ripgrep
    rm-improved
    kitty
    zip
    nnn

    # wayland utils
    grim
    wl-clipboard
    swww

    # top of the morning
    htop
    iotop
    gtop
    iftop

    discord

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
      ];
      extraGroups = [ "wheel" "audio" ];
    };
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };


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
    modesetting.enable = true;
    nvidiaSettings = true;
  };
  
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
