{ pkgs, lib, config, ... }:

let
#  cachixManual = import ./pkgs-cachix.nix pkgs;

  findImport = (import ../../../lib.nix).findImport;
  home-manager = findImport "extras" "home-manager";

  crtFilePath = "/home/cole/.mitmproxy/mitmproxy-ca-cert.pem";
  crtFile = pkgs.copyPathToStore crtFilePath;
in
{
  imports = [
    "${home-manager}/nixos"
  ];

  config = {
    users.extraGroups."cole".gid = 1000;
    users.extraUsers."cole" = {
      isNormalUser = true;
      home = "/home/cole";
      description = "Cole Mickens";
      openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9YAN+P0umXeSP/Cgd5ZvoD5gpmkdcrOjmHdonvBbptbMUbI/Zm0WahBDK0jO5vfJ/C6A1ci4quMGCRh98LRoFKFRoWdwlGFcFYcLkuG/AbE8ObNLHUxAwqrdNfIV6z0+zYi3XwVjxrEqyJ/auZRZ4JDDBha2y6Wpru8v9yg41ogeKDPgHwKOf/CKX77gCVnvkXiG5ltcEZAamEitSS8Mv8Rg/JfsUUwULb6yYGh+H6RECKriUAl9M+V11SOfv8MAdkXlYRrcqqwuDAheKxNGHEoGLBk+Fm+orRChckW1QcP89x6ioxpjN9VbJV0JARF+GgHObvvV+dGHZZL1N3jr8WtpHeJWxHPdBgTupDIA5HeL0OCoxgSyyfJncMl8odCyUqE+lqXVz+oURGeRxnIbgJ07dNnX6rFWRgQKrmdV4lt1i1F5Uux9IooYs/42sKKMUQZuBLTN4UzipPQM/DyDO01F0pdcaPEcIO+tp2U6gVytjHhZqEeqAMaUbq7a6ucAuYzczGZvkApc85nIo9jjW+4cfKZqV8BQfJM1YnflhAAplIq6b4Tzayvw1DLXd2c5rae+GlVCsVgpmOFyT6bftSon/HfxwBE4wKFYF7fo7/j6UbAeXwLafDhX+S5zSNR6so1epYlwcMLshXqyJePJNhtsRhpGLd9M3UqyGDAFoOQ== (none)"];
      #mkpasswd -m sha-512
      hashedPassword = "$6$k.vT0coFt3$BbZN9jqp6Yw75v9H/wgFs9MZfd5Ycsfthzt3Jdw8G93YhaiFjkmpY5vCvJ.HYtw0PZOye6N9tBjNS698tM3i/1";
      shell = "${pkgs.fish}/bin/fish";
      extraGroups = [ "wheel" "networkmanager" "kvm" "libvirtd" "docker" "transmission" "audio" "video" "sway" "sound" "pulse" "input" "render" "dialout" ];
      uid = 1000;
      group = "cole";
    };
    nix.trustedUsers = [ "cole" ];

    # <mitmproxy>
    security.pki.certificateFiles =
      if (lib.pathExists "${crtFilePath}")
        then [ "${crtFile}" ]
        else [];
    # </mitmproxy>

    # HM: ca.desrt.dconf error:
    services.dbus.packages = with pkgs; [ gnome3.dconf ];

    home-manager.useGlobalPkgs = true;
    home-manager.users.cole = { pkgs, ... }: {
      home.stateVersion = "20.03";
      home.sessionVariables = {
        EDITOR = "nvim";
        TERMINAL = "termite";
        TERM = "xterm-256color"; # sigh, termite
      };
      home.file = {
        ".gdbinit".source = (pkgs.writeText "gdbinit" ''set auto-load safe-path /nix/store'');
        #".local/bin/gpgssh.sh".source = ./config/bin/gpgssh.sh;
        #".local/bin/megadl.sh".source = ./config/bin/megadl.sh;
        #".local/bin/rdpsly.sh".source = ./config/bin/rdpsly.sh;
      };
      xdg.enable = true;
      xdg.configFile = {
        "gopass/config.yml".source = ./config/gopass/config.yml;
        # TODO: passrs ?s
      };
      programs = {
        bash.enable = false;
        fish = import ./config/fish-config.nix pkgs;
        git = import ./config/git-config.nix pkgs;
        gpg.enable = true;
        home-manager.enable = true;
        htop.enable = true;
        neovim = import ./config/neovim-config.nix pkgs;
        tmux = import ./config/tmux-config.nix pkgs;
        zsh.enable = false;
      };
      services = {
      };
      home.packages = with pkgs; [
        # everything non-gui goes here that I use
        #cachixManual
        wget curl
        # neovim vim # HM modules
        ripgrep jq fzf
        wget curl stow ncdu tree
        git-crypt gopass gnupg passrs
        openssh autossh mosh sshuttle
        gitAndTools.gitFull gitAndTools.hub gist tig
        cvs mercurial subversion # pjiul

        mitmproxy

        htop iotop which binutils.bintools
        unrar parallel unzip xz zip #p7zip

        nix-prefetch nixpkgs-fmt nixpkgs-review

        ffmpeg linuxPackages.cpupower
        sshfs cifs-utils ms-sys ntfs3g
        imgurbash2 spotify-tui

        gdb lldb file gptfdisk
        parted psmisc wipe

        aria2 megatools youtube-dl plowshare

        # eh?
        # TODO: ? xdg_utils
      ] ++ lib.optionals (config.system == "x86_64-linux")
        [
          esphome
        ];
    };
  };
}
