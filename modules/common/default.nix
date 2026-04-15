{ pkgs, lib, ... }:

{
  # Nixpkgs configuration
  nixpkgs.config = {
    allowUnfree = true;
    cudaSupport = true;
  };

  nix = {
    settings = {
      allowed-users = [ "@wheel" ];
      trusted-users = [ "@wheel" ];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://numtide.cachix.org"
        "https://cuda-maintainers.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Yrg+bU/s5/f/y/K5PCI4oaLY="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ber+6dwNbSd05yOb6HnGfN1gvI="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
    };
    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Timezone - adjust as needed
  time.timeZone = lib.mkDefault "Asia/Singapore";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

  # Essential system packages (available to all users)
  environment.systemPackages = with pkgs; [
    curl
    git
    inetutils
    tmux
    vim
    wget
    htop
    pciutils
    usbutils
  ];

  # Enable zsh system-wide
  programs.zsh.enable = true;

  # Docker daemon (CLI tools are in packages.nix via home-manager)
  virtualisation.docker.enable = true;

  # nix-ld for running unpatched binaries (python wheels, etc.)
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      openssl
      glib
      libglvnd
    ];
  };

  # Fonts
  fonts.packages = with pkgs; [
    dejavu_fonts
    jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
    meslo-lgs-nf
  ];

  system.stateVersion = "24.11";
}
