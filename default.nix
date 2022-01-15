{ pkgs ? import <nixpkgs> { }, compiler ? "ghc8107" }:
pkgs.pkgs.haskell.packages.${compiler}.callPackage ./package.nix { }