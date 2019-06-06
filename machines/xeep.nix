{ pkgs, ... }:

let
  lib = pkgs.lib;
  nixosHardware = builtins.fetchTarball
    "https://github.com/NixOS/nixos-hardware/archive/master.tar.gz";
  hostname = "xeep";
in
{
  imports = [
    ../modules/common.nix
    ../modules/pkgs-common.nix
    ../modules/pkgs-full.nix
    ../modules/user-cole.nix

    ../modules/profile-interactive.nix
    ../modules/profile-gui.nix
    ../modules/profile-gui-extra.nix
    ../modules/profile-sway.nix

    ../modules/mixin-coredumps.nix
    ../modules/mixin-docker.nix
    ../modules/mixin-sshd.nix
    #../modules/mixin-ipfs.nix
    ../modules/mixin-yubikey.nix

    #../modules/hw-magictrackpad2.nix
    ../modules/hw-chromecast.nix

    "${builtins.toString nixosHardware}/dell/xps/13-9370/default.nix"
  ];

  config = {
    system.stateVersion = "18.09"; # Did you read the comment?
    time.timeZone = "America/Los_Angeles";
    services.timesyncd.enable = true;

    #documentation.enable = false;
    documentation.nixos.enable = false;

    services.mingetty.autologinUser = "cole";
    #services.kmscon.enable = true;
    #services.kmscon.autologinUser = "cole";

    environment.systemPackages = with pkgs; [
      msr-tools # how to add a one off command instead of adding to full system pkgs:
    ];

    fileSystems = {
      "/" = {
        device = "/dev/vg/root";
        fsType = "ext4";
      };
      #"/"    = { device = "/dev/mapper/dmnixos"; fsType = "btrfs"; options = "subvol=root" };
      "/boot" = {
        device = "/dev/disk/by-partlabel/nixos-boot";
        fsType = "vfat";
      };
    };
    swapDevices = [ ];
    boot = {
      earlyVconsoleSetup = true; # hidpi + luks-open
      kernelPackages = pkgs.linuxPackages_latest;
      initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "intel_agp" "i915" ];
      kernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "intel_agp" "i915" ];
      kernelParams = [
        "mitigations=off"    # HIGHLY IRRESPONSIBLE
        "i915.modeset=1"     # nixos-hw = missing
        "i915.enable_guc=3"  # nixos-hw = missing
        "i915.enable_gvt=0" # nixos-hw = missing
        "i915.enable_fbc=1"  # nixos-hw = 2
        "i915.enable_psr=1"  # nixos-hw = missing?
        "i915.fastboot=1"    # nixos-hw = missing?
      ];
      supportedFilesystems = [ "btrfs" ];
      initrd.supportedFilesystems = [ "btrfs" ];
      initrd.luks.devices = [
        { 
          name = "root";
          device = "/dev/disk/by-partlabel/nixos-luks";
          preLVM = true;
          allowDiscards = true;
        }
      ];
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    };
    networking = {
      hostId = "ef66d560";
      hostName = hostname;
      firewall.enable = false;
      firewall.allowedTCPPorts = [];
      networkmanager.enable = true;
    };
    services.resolved.enable = true;

    i18n.consolePackages = [ pkgs.terminus_font ]; # hidpi
    i18n.consoleFont = "ter-v32n"; # hidpi

    nix.maxJobs = 8;
    nix.nixPath = [
      "/etc/nixos"
      "nixpkgs=/home/cole/code/nixpkgs"
      "nixos-config=/home/cole/code/nixcfg/machines/${hostname}.nix"
    ];
    
    nixpkgs.config.allowUnfree = true; # for redistrib fw
    hardware = {
      bluetooth.enable = true;
      pulseaudio.package = pkgs.pulseaudioFull;
      enableRedistributableFirmware = true;
      cpu.intel.updateMicrocode = true;
      enableAllFirmware = true;
      u2f.enable = true;

      opengl.driSupport32Bit = true;
      pulseaudio.support32Bit = true;
    };
    services.fwupd.enable = true;

    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
    powerManagement.enable = true;
    services.tlp.enable = true;
    services.upower.enable = true;
  };
}
