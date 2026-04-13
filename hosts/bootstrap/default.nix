# Bootstrap / emergency configuration for limiting-factor.
# Minimal: SSH + Tailscale + CLI tools. No GUI, no CUDA.
# Use: nixos-rebuild switch --flake .#bootstrap
{ pkgs, lib, ... }:

{
  imports = [
    ../../modules/common
    ../../modules/common/users.nix
    ../../modules/common/remote-access.nix
  ];

  # Override: no CUDA in bootstrap (faster eval, smaller closure)
  nixpkgs.config.cudaSupport = lib.mkForce false;

  networking.hostName = "limiting-factor";

  # Placeholder boot config - hardware-configuration.nix will override
  boot.loader.systemd-boot = {
    enable = lib.mkDefault true;
    configurationLimit = 20;
  };
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  # Placeholder filesystem - hardware-configuration.nix will override
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # Docker (no GPU passthrough in bootstrap)
  virtualisation.docker = {
    enable = true;
    logDriver = "json-file";
  };

  # Firewall - conservative defaults
  networking.firewall.enable = true;

  environment.systemPackages = with pkgs; [
    # Essentials for initial setup
    parted
    gptfdisk
    ntfs3g
    rsync
    lshw
  ];
}
