{ config, lib, pkgs, ... }:

let
in {
  imports = [
    ./common
    ./mixin-docker.nix
    ./mixin-libvirt.nix
    ./mixin-nginx-server.nix
    ./mixin-plex.nix
    ./mixin-samba.nix
    ./mixin-sshd.nix
    ./mixin-transmission.nix
    ./mixin-unifi.nix
    ./mixin-wireguard-server.nix
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/dc46f531-a364-4f55-a0d3-7b2441ed63a2";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/03F7-8754";
    fsType = "vfat";
  };

  fileSystems."/media/data" = {
    device = "/dev/sdc";
    fsType = "btrfs";
  };
  
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.supportedFilesystems = [ "btrfs" ];
    supportedFilesystems = [ "btrfs" ];
    initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ata_piix" "usbhid" "usb_storage" "sd_mod" "intel_agp" "i915" ];
    kernelModules = [ "xhci_pci" "ehci_pci" "ata_piix" "usbhid" "usb_storage" "sd_mod" "intel_agp" "i915" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    extraModulePackages = [ config.boot.kernelPackages.wireguard ]; # (in case we want to use wireguard w/o the module)
  };

  swapDevices = [];

  system.stateVersion = "18.09"; # Did you read the comment?
  nix.maxJobs = 4;
  networking = {
    hostName = "chimera";
    networkmanager.enable = true;
  };

  i18n.consoleFont = "Lat2-Terminus16";
  time.timeZone = "America/Los_Angeles";

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
    enableAllFirmware = true;
    u2f.enable = true;
  };

  powerManagement.enable = false;
  services.tlp.enable = false;
}

