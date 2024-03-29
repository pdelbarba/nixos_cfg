{ inputs, outputs, lib, config, pkgs, ... }: {
  # You can import other NixOS modules here
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-ssd

    ../common
    ../common/k3s.nix    
    #./users.nix

    ./hardware-configuration.nix
    ./coral.nix
    ./syncthing.nix
  ];

  # Aux drive mounts

  boot.supportedFilesystems = [ "ntfs" "zfs" ];
  boot.zfs.extraPools = [ "campool" "raidpool" ];
  services.zfs.autoScrub.enable = true;
  boot.zfs.forceImportRoot = false;
  boot.zfs.requestEncryptionCredentials = false;
  services.zfs.trim.enable = true;
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;  

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
      allowedTCPPorts = [ 22 80 443 8384 22000 ];
      allowedUDPPorts = [ 22000 21027 ];
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
  services.tailscale.extraUpFlags = [
    "--advertise-exit-node"
  ];

  environment.systemPackages = with pkgs; [
    # server stuff
    sqlite

    # web cli tools
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
    lsof
    nvd

    #flatbuffers
    #libedgetpu
    #linuxKernel.packages.linux_6_6.gasket

    # top of the morning
    htop
    iotop
    gtop
    iftop
    btop

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

  # TODO: move to another file under common
  users.users = {
    patrick = {
      initialPassword = "a4b3c2d1";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAaRp0/N4pol7BxSkK0W+ofqmUogRQ/vvrDTipqo7oIb patrick@solaros"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHx5z0WQb4t6Q0P98XZhw+0DC9X7p+m4qNJUXhmbXCK4 patrick@phone"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCofzNUpAto0yXck+PF2xfmX4SVigk2J+kSAP5BXOBoYQNmR+KIRHXBN+iUBY1LrBeNAwaA2/g38qSwrRzPboaLip/kr34f7KbvfgwshjmVvVwa7DFA2IEcA3j1EgsW/9HWH1k9QnejNiEinTt+hoUKxcY984fPRNyCwWEeJfRfhfMPgeCh0uM+LQ8KeK+VDoKXbnqHVy3AzSXacvK/XEyMPw68ovCHesV+s0t7aqtUBLx2N7VU8WxxrbbusddptvqbkC1uhgRdHd1JVdsb0Vnv8BV8b2ehYAl6Tzvl5yCWZ2GGc540dveGGnoZkxG0KgDNSzgF4mVk2CPMseuOsIaUCxUN9LRQA56/gJFe1RC8bANqvtjoFMURCGV05DaPNVVBnPKEXr1QYm5I36oqitpe1VZjkDMvuuqtbVdjUAD2Lu+WHkCPuDRgcBGjE2suJw32WyF9sTP2R6xTgv81iaegdokng4/YyMJCCMekI7lMsxvUJ/DgS/vL006OOq6arUc= patrick@eoi-patrick-lt"
      ];
      extraGroups = [ "wheel" ];
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
