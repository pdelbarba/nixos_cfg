{
  description = "SolarOS test flake please ignore";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    helix.url = "github:helix-editor/helix/23.05";
    
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dotfiles = {
      url = "gitlab:aoeuid/dotfiles"; # TODO probably want to clean this up?
      flake = false;
    };
  };

  outputs = inputs @ { nixpkgs, home-manager, hyprland, hyprland-contrib, helix, dotfiles, ... }: let
    system = "x86_64-linux";
    specialArgs = { inherit home-manager hyprland hyprland-contrib helix dotfiles; };
    inputModules = [
      hyprland.nixosModules.default
      {
        programs.hyprland.enable = true;
        programs.hyprland.xwayland.enable = true;
        programs.hyprland.nvidiaPatches = true;
      }

      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = specialArgs;
        home-manager.users.solar = {
          imports = [
            hyprland.homeManagerModules.default # OK, What The Fuck. Why does having this make the way.winMan.hypr line work...?
            ./home.nix
          ];
        };
      }
      ./configuration.nix
    ];
    
  in {
    nixosConfigurations."solaros" = nixpkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules = inputModules ++ [];# TODO modularize stuff I guess
    };
  };
}