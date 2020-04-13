let
  pkgs = import /home/cole/code/nixpkgs {};
  cachixpkgs = (import (builtins.fetchTarball { url = "https://cachix.org/api/v1/install"; }) {});
in
pkgs.stdenv.mkDerivation {
  name = "nixcfg-devenv";

  nativeBuildInputs = []
  ++ (with cachixpkgs; [ cachix ])
  ++ (with pkgs; [
    bash
    cacert
    curl
    git
    jq
    mercurial
    nix
    openssh
    ripgrep
  ]);
}
