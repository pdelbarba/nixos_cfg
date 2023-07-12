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

  outputs = inputs @ { nixpkgs, home-manager, hyprland, hyprland-contrib, helix, ... }: let
    system = "x86_64-linux";
    specialArgs = { inherit home-manager hyprland hyprland-contrib helix; };
    inputModules = [
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
        home-manager.extraSpecialArgs = specialArgs;
        home-manager.users.solar = {
          imports = [
            ./home.nix
            hyprland.homeManagerModules.default # OK, What The Fuck. Why does having this make the way.winMan.hypr line work...?
          ];

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
            extraConfig = ''
              env = WLR_NO_HARDWARE_CURSORS,1
              input {
                kb_layout = us
                kb_variant = dvorak
                force_no_accel = true
              }


              # See https://wiki.hyprland.org/Configuring/Monitors/
              monitor=,preferred,auto,auto


              # See https://wiki.hyprland.org/Configuring/Keywords/ for more

              # Execute your favorite apps at launch
              # exec-once = waybar & hyprpaper & firefox

              # Source a file (multi-file configs)
              # source = ~/.config/hypr/myColors.conf

              # Some default env vars.
              env = XCURSOR_SIZE,24

              # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
              input {
                 follow_mouse = 1


                  sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
              }

              general {
                  # See https://wiki.hyprland.org/Configuring/Variables/ for more

                  gaps_in = 5
                  gaps_out = 20
                  border_size = 2
                  col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
                  col.inactive_border = rgba(595959aa)

                  layout = dwindle
              }

              decoration {
                  # See https://wiki.hyprland.org/Configuring/Variables/ for more

                  rounding = 10
                  blur = yes
                  blur_size = 3
                  blur_passes = 1
                  blur_new_optimizations = on

                  drop_shadow = yes
                  shadow_range = 4
                  shadow_render_power = 3
                  col.shadow = rgba(1a1a1aee)
              }

              animations {
                  enabled = yes

                  # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

                  bezier = myBezier, 0.05, 0.9, 0.1, 1.05

                  animation = windows, 1, 7, myBezier
                  animation = windowsOut, 1, 7, default, popin 80%
                  animation = border, 1, 10, default
                  animation = borderangle, 1, 8, default
                  animation = fade, 1, 7, default
                  animation = workspaces, 1, 6, default
              }

              dwindle {
                  # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
                  pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
                  preserve_split = yes # you probably want this
              }

              master {
                  # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
                  new_is_master = true
              }

              gestures {
                  # See https://wiki.hyprland.org/Configuring/Variables/ for more
                  workspace_swipe = off
              }

              # Example per-device config
              # See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
              device:epic-mouse-v1 {
                  sensitivity = -0.5
              }

              # Example windowrule v1
              # windowrule = float, ^(kitty)$
              # Example windowrule v2
              # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
              # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more


              # See https://wiki.hyprland.org/Configuring/Keywords/ for more
              $mainMod = SUPER

              # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
              bind = $mainMod, Q, exec, kitty
              bind = $mainMod, C, killactive, 
              bind = $mainMod, M, exit, 
              bind = $mainMod, E, exec, dolphin
              bind = $mainMod, V, togglefloating, 
              bind = $mainMod, R, exec, wofi --show drun
              bind = $mainMod, P, pseudo, # dwindle
              bind = $mainMod, J, togglesplit, # dwindle

              # Move focus with mainMod + arrow keys
              bind = $mainMod, left, movefocus, l
              bind = $mainMod, right, movefocus, r
              bind = $mainMod, up, movefocus, u
              bind = $mainMod, down, movefocus, d

              # Switch workspaces with mainMod + [0-9]
              bind = $mainMod, 1, workspace, 1
              bind = $mainMod, 2, workspace, 2
              bind = $mainMod, 3, workspace, 3
              bind = $mainMod, 4, workspace, 4
              bind = $mainMod, 5, workspace, 5
              bind = $mainMod, 6, workspace, 6
              bind = $mainMod, 7, workspace, 7
              bind = $mainMod, 8, workspace, 8
              bind = $mainMod, 9, workspace, 9
              bind = $mainMod, 0, workspace, 10

              # Move active window to a workspace with mainMod + SHIFT + [0-9]
              bind = $mainMod SHIFT, 1, movetoworkspace, 1
              bind = $mainMod SHIFT, 2, movetoworkspace, 2
              bind = $mainMod SHIFT, 3, movetoworkspace, 3
              bind = $mainMod SHIFT, 4, movetoworkspace, 4
              bind = $mainMod SHIFT, 5, movetoworkspace, 5
              bind = $mainMod SHIFT, 6, movetoworkspace, 6
              bind = $mainMod SHIFT, 7, movetoworkspace, 7
              bind = $mainMod SHIFT, 8, movetoworkspace, 8
              bind = $mainMod SHIFT, 9, movetoworkspace, 9
              bind = $mainMod SHIFT, 0, movetoworkspace, 10

              # Scroll through existing workspaces with mainMod + scroll
              bind = $mainMod, mouse_down, workspace, e+1
              bind = $mainMod, mouse_up, workspace, e-1

              # Move/resize windows with mainMod + LMB/RMB and dragging
              bindm = $mainMod, mouse:272, movewindow
              bindm = $mainMod, mouse:273, resizewindow

            '';
          };
        };
      }

      #hyprland.homeManagerModules.default
      #{
      #  wayland.windowManager.hyprland.enable = true;
      #}
      ./configuration.nix
    ];
    
  in {
    nixosConfigurations."solaros" = nixpkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules = inputModules ++ [];# TODO modularize stuff I guess
    };
  };
}


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

