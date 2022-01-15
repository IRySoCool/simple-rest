{ compiler ? "ghc8107" } :
let
  # Pinning Nixpkgs
  pkgs = import (builtins.fetchGit {
    name = "pinning-2022-01-15";
    url = "https://github.com/NixOS/nixpkgs/";
    ref = "refs/heads/nixos-21.05";
    rev = "c9a97ff47bb0db44f4a504015a5d1cedb3094c85";
  }) {}; 

  # select haskell pacakages under the given compiler version
  haskellPackages = pkgs.pkgs.haskell.packages.${compiler};

  myPkg = (import ./. { inherit pkgs compiler; });
in
haskellPackages.shellFor {

  packages = p: [ myPkg ];
  
  withHoogle = true;
  
  buildInputs = with haskellPackages; [
    haskell-language-server 
    implicit-hie
  ];
}