{ pkgs, lib, ... }:

{
  # SSH
  services.openssh = {
    enable = true;
    openFirewall = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  # Tailscale - primary remote access method
  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # Allow tailscale UDP
  networking.firewall.allowedUDPPorts = [ 41641 ];
}
