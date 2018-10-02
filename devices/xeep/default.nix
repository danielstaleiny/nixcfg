{ config, lib, pkgs, ... }:

let
in {
  imports = [
    ../../profiles/gui
    ./hardware-configuration.nix
  ];

  # TODO: reorganize this?
  # vaapi stuff
  environment.systemPackages = with pkgs; [ libva libva-full libva-utils ];

  system.stateVersion = "18.09";

  userOptions.cole = { tmuxColor="magenta"; bashColor="1;35"; };

  time.timeZone = "America/Los_Angeles";

  # hidpi stuff
  boot.earlyVconsoleSetup = true;
  fonts.fonts = with pkgs; [ terminus_font ];
  i18n.consolePackages = [ pkgs.terminus_font ];
  i18n.consoleFont = "ter-v32n";

  # ignore psmouse, errors on Dell HW
  boot.blacklistedKernelModules = [ "psmouse" ];

  # newer kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModulePackages = [
    config.boot.kernelPackages.wireguard # err, why (is this to get it in, wihtout the module?)
    # TODO: conflicts with the builtin one in tree
    # TODO: maybe just patch the existing one
    #pkgs.linuxPackages_latest.rtl8153
  ];

  services.fwupd.enable = true;

  nix.nixPath = [ "/etc/nixos" "nixpkgs=/etc/nixpkgs" "nixos-config=/etc/nixos/configuration.nix" ];

  hardware = {
    bluetooth.enable = true;
    opengl.extraPackages = with pkgs; [ vaapiIntel ];
    pulseaudio.package = pkgs.pulseaudioFull;
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
    #enableAllFirmware = true;
    u2f.enable = true;
  };

  powerManagement.enable = true;
  services.tlp.enable = true;

  networking = {
    hostName = "xeep";
    firewall.allowedTCPPorts = [ 3000 ];
    networkmanager.enable = true;
  };
}
