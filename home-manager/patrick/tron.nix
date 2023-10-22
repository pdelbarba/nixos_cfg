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

  
  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [
    # CMD utils
    sqlite
    k3s
    helm
    nmap
    hyfetch

    # Networking tools
    wireguard-tools

    joshuto
    nnn
  ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userEmail = "patrick@useless.systems";
    userName = "Patrick DelBarba";
  };
  programs.helix.enable = true;

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  home.file."/home/patrick/.config/hyfetch.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/dotfiles/hyfetch.json";
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

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
