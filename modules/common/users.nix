{ pkgs, lib, ... }:

let
  sshKeys = [
    # elijah's SSH keys (from dotfiles/nixos-config)
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL+PwhQForZ4G/u3ZP1F71yiviPLPr203qOlnwVxyau5"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7vyAECB207cv54kxjZbpAAeKnZSH66CNidIhLrvy1+"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvFKZwpaJM2I15kX/TmaZDOnfNx3LoSPsrt2XTjmk+1"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHdQ9A08MRPfAykqUPy2aKO7NSNnixhKW3Xa7N7yTHc3"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOk8iAnIaa1deoc7jw8YACPNVka1ZFJxhnU4G74TmS+p"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDlOVZ9KcD3aokJ6r9ex0c1eOJX72eiQvY8eDlcQolqh"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJhFpUfIbtvUjCO15YjsuyN9PjFLgNegURfmGoyJjEOV"
  ];
in
{
  # Primary user
  users.users.elijah = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Elijah";
    extraGroups = [
      "wheel"
      "docker"
      "video"      # GPU access
      "render"     # GPU rendering
    ];
    openssh.authorizedKeys.keys = sshKeys;
  };

  # Root SSH access for initial setup / emergency
  users.users.root.openssh.authorizedKeys.keys = sshKeys;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };
}
