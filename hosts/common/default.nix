# This file (and the global directory) holds config that i use on all hosts
{ inputs, outputs, lib, pkgs, ... }: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./default_shell.nix
    ./ssh.nix
    #./optin_persistence.nix
    ./tailscale.nix
    #./helix.nix
  ] ++ (builtins.attrValues outputs.nixosModules);

  home-manager.extraSpecialArgs = { inherit inputs outputs; };

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
    };
  };

  # TODO might not be needed?
  environment.profileRelativeSessionVariables = {
    QT_PLUGIN_PATH = [ "/lib/qt-6/plugins" ];
  };

  environment.enableAllTerminfo = true;

  hardware.enableRedistributableFirmware = true;
  #networking.domain = "fixme"; # TODO do I need this?
  
  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    supportedLocales = lib.mkDefault [
      "en_US.UTF-8/UTF-8"
    ];
  };

  console = {
    earlySetup = true;
    packages = with pkgs; [ terminus_font ];
    font = "ter-u28n";
    keyMap = "dvorak";
  };

  nix = {
    settings = {
      trusted-users = [ "root" "@wheel" ];
      auto-optimise-store = lib.mkDefault true;
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      # Keep the last 3 generations
      options = "--delete-older-than +20";
    };
  };
}

