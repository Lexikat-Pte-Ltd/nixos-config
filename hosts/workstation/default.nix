# Full workstation configuration for limiting-factor.
# GNOME desktop + Pop Shell tiling, 2x RTX 4090, CUDA, Docker + GPU passthrough.
# Use: nixos-rebuild switch --flake .#limiting-factor
{ config, pkgs, lib, ... }:

{
  imports = [
    ../../hardware-configuration.nix
    ../../modules/common
    ../../modules/common/users.nix
    ../../modules/common/remote-access.nix
    ./gpu.nix
    ./gui.nix
    ./power.nix
  ];

  networking.hostName = "limiting-factor";

  # Boot
  boot.loader.systemd-boot = {
    enable = lib.mkDefault true;
    configurationLimit = 42;
  };
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  # Placeholder filesystem - hardware-configuration.nix will override
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # Docker with GPU support
  virtualisation.docker = {
    enable = true;
    logDriver = "json-file";
    daemon.settings = {
      features.cdi = true;
      "cdi-spec-dirs" = [ "/etc/cdi" ];
    };
  };

  # Networking
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  # Additional workstation packages
  environment.systemPackages = with pkgs; [
    # System tools
    parted
    gptfdisk
    lshw
    rsync

    # Development
    gnumake
    cmake

    # Media / productivity
    vlc
    google-chrome
    xclip
    wl-clipboard

    # Monitoring
    nvtopPackages.nvidia
    lm_sensors
  ];

  # Enable envfs for compatibility with scripts expecting /usr/bin/env
  services.envfs.enable = true;

  # Syncthing for file sync
  services.syncthing = {
    enable = true;
    user = "elijah";
    dataDir = "/home/elijah";
    configDir = "/home/elijah/.config/syncthing";
    openDefaultPorts = true;
  };
}
