{ pkgs, ... }:

let
  overlay = (import ../lib.nix {}).overlay;
  _useOverlay = builtins.pathExists ../../overlays/nixpkgs-graphics;
  useOverlay = false;
in
{
  config = {
    # we're using the overlay for now:
    hardware.opengl.package =
      if useOverlay
      then pkgs.mesa.drivers
      else (pkgs.mesa.override {
        galliumDrivers = [ "virgl" "svga" "swrast" "iris" ];
        driDrivers = [ "i915" "i965" ];
        vulkanDrivers = [ "intel" ];
      }).drivers;

    nixpkgs.overlays =
      if useOverlay
      then [ (overlay "nixpkgs-graphics") ]
      else [];

    environment.variables = {
      #MESA_LOADER_DRIVER_OVERRIDE = "iris";
    };
  };
}
