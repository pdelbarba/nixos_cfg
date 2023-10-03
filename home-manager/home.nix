# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, outputs, lib, config, pkgs, rust-overlay, ... }: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      #rust-overlay.overlays.default
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
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

#  environment.systemPackages = [ pkgs.rust-bin.stable.latest.default ];

  home = {
    username = "patrick";
    homeDirectory = "/home/patrick";
  };

  home.sessionVariables = {
    WALLPAPER_PATH = "/home/patrick/wallpapers/wallhaven-o3z85l.png";
  };
  
  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [
    # Desktop applications
    steam
    firefox
    telegram-desktop
    libsForQt5.kdeconnect-kde
    spotify
    joplin-desktop
    kicad
    lutris
    mpv
    discord

    # CMD utils
    yt-dlp
    sqlite

    # Sound
    pavucontrol

    # EWW dependencie
    eww-wayland
    pamixer
    socat
    jq
    pulseaudio

    # Networking tools
    wireguard-tools

    # Utils for Hyprland    
    wofi
    swww
    dunst
    dex
    libnotify
    hyfetch
    slurp
    joshuto
    pcmanfm

  ];

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      ignore-empty-password = true;
      #image = "${config.wallpaper}";
      indicator = true;
      indicator-idle-visible = true;
      indicator-caps-lock = true;
      indicator-radius = 100;
      indicator-thickness = 16;
      line-uses-inside = true;
      effect-blur = "9x7";
      effect-vignette = "0.85:0.85";
      fade-in = 0.1;
    };
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userEmail = "patrick@useless.systems";
    userName = "Patrick DelBarba";
  };
  programs.helix.enable = true;

  services.swayidle = {
    enable = true;
    events = [
      { event = "before-sleep"; command = "swaylock"; }
    ];
    timeouts = [
      { timeout = 450; command = "swaylock"; }
    ];
  };


  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
  };

  home.file."/home/patrick/.config/hypr" = {
    source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/dotfiles/hypr";
    recursive = true;
  };

  home.file."/home/patrick/.config/hyfetch.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/dotfiles/hyfetch.json";
    recursive = true;
  };

  home.file."/home/patrick/.config/dunst" = {
    source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/dotfiles/dunst";
    recursive = true;
  };

  home.file."/home/patrick/.config/eww" = {
    source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/dotfiles/eww";
    recursive = true;
  };

  home.file."/home/patrick/.config/fish" = {
    source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/dotfiles/fish";
    recursive = true;
  };

  home.file."/home/patrick/.config/helix" = {
    source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/dotfiles/helix";
    recursive = true;
  };

  home.file."/home/patrick/.config/gitui" = {
    source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/dotfiles/gitui";
    recursive = true;
  };


  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
