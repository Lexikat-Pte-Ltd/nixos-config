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

  # NVIDIA container toolkit for Docker GPU passthrough.
  # This enables the upstream `nvidia-container-toolkit-cdi-generator.service`,
  # which writes /etc/cdi/nvidia.yaml on boot (with `ExecStartPre=udevadm settle`
  # so it waits for the kernel module to appear). Do NOT add a manual
  # nvidia-cdi-generator service on top — it duplicates the work and races
  # against driver load on first boot.
  hardware.nvidia-container-toolkit.enable = true;

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
