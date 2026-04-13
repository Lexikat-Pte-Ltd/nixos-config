# User definitions for limiting-factor.
#
# To add yourself, create an entry in users.users below and (optionally) a
# home-manager profile in modules/home/<you>.nix — see modules/home/elijah.nix
# as an example. Then register it in flake.nix under hmUsers.
{ pkgs, lib, ... }:

{
  # ── Elijah ─────────────────────────────────────────────────────────────
  users.users.elijah = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Elijah";
    extraGroups = [ "wheel" "docker" "video" "render" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL+PwhQForZ4G/u3ZP1F71yiviPLPr203qOlnwVxyau5"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7vyAECB207cv54kxjZbpAAeKnZSH66CNidIhLrvy1+"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvFKZwpaJM2I15kX/TmaZDOnfNx3LoSPsrt2XTjmk+1"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHdQ9A08MRPfAykqUPy2aKO7NSNnixhKW3Xa7N7yTHc3"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOk8iAnIaa1deoc7jw8YACPNVka1ZFJxhnU4G74TmS+p"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDlOVZ9KcD3aokJ6r9ex0c1eOJX72eiQvY8eDlcQolqh"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJhFpUfIbtvUjCO15YjsuyN9PjFLgNegURfmGoyJjEOV"
    ];
  };

  # ── Example: add another user ─────────────────────────────────────────
  # users.users.alice = {
  #   isNormalUser = true;
  #   shell = pkgs.zsh;
  #   description = "Alice";
  #   extraGroups = [ "docker" "video" "render" ];
  #   openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA..." ];
  # };

  # Root gets elijah's keys for emergency access during initial setup.
  # Remove or extend once the machine is stable.
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDlOVZ9KcD3aokJ6r9ex0c1eOJX72eiQvY8eDlcQolqh"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJhFpUfIbtvUjCO15YjsuyN9PjFLgNegURfmGoyJjEOV"
  ];

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };
}
