{ pkgs, ... }:
let
  lib = pkgs.lib;
  findImport = (import ../../lib.nix).findImport;
  nixosHardware = findImport "extras" "nixos-hardware";

  hostname = "xeep";
in
{
  imports = [
    #./power-management.nix
    ../../config/common.nix

    ../../config/mixin-docker.nix
    ../../config/mixin-libvirt.nix
    #../../config/mixin-plex-mpv.nix
    ../../config/mixin-sshd.nix

    ../../config/loremipsum-media/rclone-cmd.nix
    ../../config/mixin-v4l2loopback.nix
    ../../config/hw-chromecast.nix

    ../../modules/default.nix # include all my custom modules

    ../../home/users/cole/default.nix # include HM (this includes its own custom HM modules)
    ../../home/users/cole/gui.nix

    "${nixosHardware}/dell/xps/13-9370/default.nix"
  ];

  config = {
    # <relocate>
    # TODO
    services.udev.packages = with pkgs; [ libsigrok ];
    services.ratbagd.enable = true;
    environment.systemPackages = with pkgs; [
      libratbag
      piper
      undervolt
      (
        pkgs.writeScriptBin "dell-fix-power" ''
          #!/usr/bin/env bash
          oldval="$(sudo ${pkgs.msr-tools}/bin/rdmsr 0x1FC)"
          newval="$(( 0xFFFFFFFE & 0x$oldval ))"
          sudo ${pkgs.msr-tools}/bin/wrmsr -a 0x1FC "$val"
        ''
      )
    ];
    # </relocate>

    system.stateVersion = "18.09"; # Did you read the comment?
    services.timesyncd.enable = true;
    nix.nixPath = [];
    documentation.nixos.enable = false;

    fileSystems = {
      "/" = { fsType = "zfs"; device = "rpool2/nixos"; };
      "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/nixos-boot"; };
      "/home" = { fsType = "zfs"; device = "rpool2/home"; };
    };
    swapDevices = [];

    console.earlySetup = true; # hidpi + luks-open  # TODO : STILL NEEDED?
    console.font = "ter-v32n";
    console.packages = [ pkgs.terminus_font ];

    boot = {
      zfs.requestEncryptionCredentials = true;
      kernelPackages = pkgs.linuxPackages_latest;
      initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "intel_agp" "i915" ];
      kernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "intel_agp" "i915" ];
      kernelParams = [
        # HIGHLY IRRESPONSIBLE
        "noibrs"
        "noibpb"
        "nopti"
        "nospectre_v2"
        "nospectre_v1"
        "l1tf=off"
        "nospec_store_bypass_disable"
        "no_stf_barrier"
        "mds=off"
        "mitigations=off"

        "i915.modeset=1" # nixos-hw = missing
        "i915.enable_guc=3" # nixos-hw = missing
        "i915.enable_gvt=0" # nixos-hw = missing
        "i915.enable_fbc=1" # nixos-hw = 2
        "i915.enable_psr=1" # nixos-hw = missing?
        "i915.fastboot=1" # nixos-hw = missing?
      ];
      supportedFilesystems = [ "btrfs" "zfs" ];
      initrd.supportedFilesystems = [ "btrfs" "zfs" ];
      loader = {
        timeout = 1;
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    };
    networking = {
      hostId = "ef66d560";
      hostName = hostname;
      firewall = {
        enable = true;
        allowedTCPPorts = [ 5900 22 ];
        checkReversePath = "loose";
      };
      networkmanager.enable = true;
      networkmanager.wifi.backend = "iwd";
      wireguard.enable = true;
    };
    services.resolved.enable = true;

    nix.maxJobs = 8;
    nixpkgs.config.allowUnfree = true;
    hardware = {
      bluetooth.enable = true;
      pulseaudio.package = pkgs.pulseaudioFull;
      enableRedistributableFirmware = true;
      cpu.intel.updateMicrocode = true;
      u2f.enable = true;
    };
    services.fwupd.enable = true;
  };
}
