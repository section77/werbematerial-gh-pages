{ pkgs }:
import (pkgs.fetchFromGitHub {
  owner = "justinwoo";
  repo = "easy-purescript-nix";
  rev = "c76bf87dd66a98127569bb563f49b01cdb7204b0";
  sha256 = "15kni4di02y2kk89x4zsjyr42bhc2h1n9qx3xbwlmmsbhi5d6lz4";
})

