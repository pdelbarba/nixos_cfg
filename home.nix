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
  ];

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
