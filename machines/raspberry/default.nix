let
  lib = import ../../lib.nix;
  system = lib.mkSystem {
    nixpkgs = lib.findNixpkgs "rpi";
    extraModules = [ ./configuration.nix ];
    system = "aarch64-linux";
  };
in
system.config.system.build.toplevel
