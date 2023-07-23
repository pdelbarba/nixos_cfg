# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, helix, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  #############################################################################
  ### Disks
  #############################################################################

  fileSystems = {
    "/".options = [ "compress=zstd" "noatime" ];
    "/home".options = [ "compress=zstd" "noatime" ];
    "/nix".options = [ "compress=zstd" "noatime" ];
    "/persist".options = [ "compress=zstd" "noatime" ];
    "/var/log".options = [ "compress=zstd" "noatime" ];
  };

  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
  
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    enableCryptodisk = true;
    configurationLimit = 40;
  };
  
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/f7345333-5210-4707-9553-7fc7cc000f1a";
      preLVM = true;
    };
  }; 

  #############################################################################
  ### Locale
  #############################################################################

  # Set your time zone.
  time.timeZone = "US/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "dvorak";
  };

  #############################################################################
  ### Printer
  #############################################################################

  # Enable CUPS to print documents.
  services.printing.enable = true;
  
  #############################################################################
  ### Sound
  #############################################################################


  # Enable sound.
  sound.enable = true;
  # hardware.pulseaudio.enable = true;
  
  #############################################################################
  ### Users
  #############################################################################

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.solar = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      firefox
    ];
  };

  #############################################################################
  ### System Packages
  #############################################################################

  environment.variables = rec { # rec statement allows list elements to ref each other
    EDITOR = "hx";
    
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
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
    kitty

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

    helix.packages."${pkgs.system}".helix   
 
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

  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  environment.shells = with pkgs; [ fish ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  #############################################################################
  ### Networking
  #############################################################################

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
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
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  #############################################################################
  ### Nvidia :(
  #############################################################################
  
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

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

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).

  system.stateVersion = "23.05"; # Did you read the comment?

}
