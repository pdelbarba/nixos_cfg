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

    #alacritty = {
    #  url = "github:alacritty/alacritty/v0.12.1";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
  };

  outputs = inputs@{ self, nixpkgs, hyprland, home-manager, ... }: {
    nixosConfigurations = {
      solaros = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          hyprland.nixosModules.default
          {
            programs.hyprland.enable = true;
            programs.hyprland.xwayland.enable = true;
            programs.hyprland.nvidiaPatches = true;
          }

          #options.wayland.windowManager.hyprland {
          #  extraConfig = ''
          #    input {
          #      kb_variant = "dvorak"
          #      force_no_accell = true
          #    }
          #  '';
          #}
          

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.solar = import ./home.nix;
            home-manager.extraSpecialArgs = inputs;
          }

          #hyprland.homeManagerModules.default
          #{
          #  wayland.windowManager.hyprland.enable = true;
          #}
          ./configuration.nix
       ];
      };
    };
  };


  # The nixpkgs entry in the flake registry.
  #inputs.nixpkgsRegistry.url = "nixpkgs";

  # The nixpkgs entry in the flake registry, overriding it to use a specific Git revision.
  #inputs.nixpkgsRegistryOverride.url = "nixpkgs/a3a3dda3bacf61e8a39258a0ed9c924eeca8e293";

  # The master branch of the NixOS/nixpkgs repository on GitHub.
  #inputs.nixpkgsGitHub.url = "github:NixOS/nixpkgs";

  # The nixos-20.09 branch of the NixOS/nixpkgs repository on GitHub.
  #inputs.nixpkgsGitHubBranch.url = "github:NixOS/nixpkgs/nixos-20.09";

  # A specific revision of the NixOS/nixpkgs repository on GitHub.
  #inputs.nixpkgsGitHubRevision.url = "github:NixOS/nixpkgs/a3a3dda3bacf61e8a39258a0ed9c924eeca8e293";

  # A flake in a subdirectory of a GitHub repository.
  #inputs.nixpkgsGitHubDir.url = "github:edolstra/nix-warez?dir=blender";

  # A git repository.
  #inputs.gitRepo.url = "git+https://github.com/NixOS/patchelf";

  # A specific branch of a Git repository.
  #inputs.gitRepoBranch.url = "git+https://github.com/NixOS/patchelf?ref=master";

  # A specific revision of a Git repository.
  #inputs.gitRepoRev.url = "git+https://github.com/NixOS/patchelf?ref=master&rev=f34751b88bd07d7f44f5cd3200fb4122bf916c7e";

  # A tarball flake
  #inputs.tarFlake.url = "https://github.com/NixOS/patchelf/archive/master.tar.gz";

  # A GitHub repository.
  #inputs.import-cargo = {
  #  type = "github";
  #  owner = "edolstra";
  #  repo = "import-cargo";
  #};

  # Inputs as attrsets.
  # An indirection through the flake registry.
  #inputs.nixpkgsIndirect = {
  #  type = "indirect";
  #  id = "nixpkgs";
  #};

}
