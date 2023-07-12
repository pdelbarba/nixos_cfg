{ config, pkgs, ... }:

{
    home.username = "solar";
    home.homeDirectory = "/home/solar";

    programs.git = {
      enable = true;
      userName = "Patrick";
      userEmail = "patrick@useless.systems";
    };

    #home.packages = [
    #  pkgs.zip
    #  pkgs.nnn
    #  #pkgs.kitty
    #];

    programs.starship = {
      enable = true;
      settings = {
        add_newline = true;
        aws.disabled = true;
        gcloud.disabled = true;
        line_break.disabled = true;
      };
    };

    #wayland.windowManager.hyprland = {
    #  extraConfig = ''
    #    input {
    #      kb_variant = "dvorak"
    #      force_no_accel = true
    #    }
    #  '';
    #};

    programs.fish = { # TODO add rust bins I guess...?
      interactiveShellInit = ''
        fish_add_path $HOME/bin $HOME/.local/bin $HOME/go/bin
      '';
    };

    #programs.kitty = {
    #  enable = true;
    #};

    #programs.alacritty = {
    #  enable = true;
    #  env.TERM = "xterm-256color";
    #  font = {
    #    size = 12;
    #    draw_bold_text_with_bright_colors = true;
    #  };
    #  scrolling.multiplier = 5;
    #  selection.save_to_clipboard = true;
    #};

    home.stateVersion = "23.05";

    programs.home-manager.enable = true;
    
}
