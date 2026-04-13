# NVIDIA GPU configuration for 2x RTX 4090.
# Proprietary drivers + CUDA toolkit + container toolkit for Docker GPU passthrough.
{ config, pkgs, lib, ... }:

{
  # NVIDIA proprietary drivers
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    # Use the production driver branch (latest stable)
    package = config.boot.kernelPackages.nvidiaPackages.production;

    # Modesetting is required for Wayland and most compositors
    modesetting.enable = true;

    # Power management - disable for a workstation (always on)
    powerManagement.enable = false;

    # Enable the open-source kernel module (supported on RTX 4090, Turing+)
    # Set to false if you encounter issues; proprietary fallback is always safe
    open = true;

    # nvidia-settings GUI for driver tuning
    nvidiaSettings = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  # CUDA toolkit available system-wide
  environment.systemPackages = with pkgs; [
    cudatoolkit
  ];

  # CUDA environment variables
  environment.variables = {
    CUDA_PATH = "${pkgs.cudatoolkit}";
  };

  # NVIDIA container toolkit for Docker GPU passthrough
  hardware.nvidia-container-toolkit.enable = true;

  # Generate CDI spec so Docker can discover GPUs
  systemd.services.nvidia-cdi-generator = {
    description = "Generate NVIDIA CDI spec for container GPU access";
    wantedBy = [ "multi-user.target" ];
    after = [ "nvidia-persistenced.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.nvidia-container-toolkit}/bin/nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml --nvidia-ctk-path=${pkgs.nvidia-container-toolkit}/bin/nvidia-ctk";
    };
  };

  # nix-ld libraries for CUDA applications (python wheels, etc.)
  programs.nix-ld.libraries = with pkgs; [
    cudatoolkit
    cudatoolkit.lib
    libglvnd
    linuxPackages.nvidia_x11
  ];

  # Kernel parameters for multi-GPU stability
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];
}
