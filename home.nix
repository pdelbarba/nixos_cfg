{ config, pkgs, dotfiles, ... }:

let
  inherit (builtins) readFile;
in{
  home.username = "solar";
  home.homeDirectory = "/home/solar";

  programs.git = {
    enable = true;
    userName = "Patrick";
    userEmail = "patrick@useless.systems";
  };

  home.packages = [
    pkgs.zip
    pkgs.nnn
    pkgs.kitty
    pkgs.wofi
    pkgs.steam
    pkgs.telegram-desktop
    pkgs.eww-wayland
    pkgs.dunst
    pkgs.dex
    pkgs.libnotify
    pkgs.hyfetch
    pkgs.slurp
    pkgs.joshuto
    pkgs.libsForQt5.dolphin
    ];

  #icmds.lock = "swaylock";

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

  programs.fish = { # TODO add rust bins I guess...?
    interactiveShellInit = ''
      fish_add_path $HOME/bin $HOME/.local/bin $HOME/go/bin
    '';
  };

  programs.kitty = {
    enable = true;
  };


  wayland.windowManager.hyprland = {
    enable = true;
    nvidiaPatches = true;
    recommendedEnvironment = true;
    xwayland = {
      enable = true;
      #hidpi = true; # future use???
    };
    #xtraConfig =
    #  readFile "${config.home.homeDirectory}/.config/nixos_files/dotfiles/hypr/hyprland.conf";
  };

  #xdg.dataFile.hyprland.source = "${dotfiles}/hypr/hyprland.conf";

  home.file."${config.xdg.configHome}" = {
    source = dotfiles;
    recursive = true;
  };

  home.stateVersion = "23.05";

  programs.home-manager.enable = true;
}
