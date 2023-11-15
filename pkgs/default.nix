# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'

{ pkgs ? (import ../nixpkgs.nix) { } }: {
  # package to get google coral working correctly
  libedgetpu = pkgs.callPackage ./libedgetpu { };
  # gasket = pkgs.callPackage ./gasket { };
}
