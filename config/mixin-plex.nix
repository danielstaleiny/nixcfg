{
  nixpkgs.config.allowUnfree = true;
  networking.firewall.allowedTCPPorts = [ 32400 ];
  services = {
    plex = {
      enable = true;
    };
  };
}
