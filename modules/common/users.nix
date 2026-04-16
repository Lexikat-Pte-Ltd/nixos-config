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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDlOVZ9KcD3aokJ6r9ex0c1eOJX72eiQvY8eDlcQolqh"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJhFpUfIbtvUjCO15YjsuyN9PjFLgNegURfmGoyJjEOV"
    ];
    initialPassword = "admin";
  };

  # ── Example: add another user ─────────────────────────────────────────
  # users.users.alice = {
  #   isNormalUser = true;
  #   shell = pkgs.zsh;
  #   description = "Alice";
  #   extraGroups = [ "docker" "video" "render" ];
  #   openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA..." ];
  # };

  # Remove or extend once the machine is stable.
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDlOVZ9KcD3aokJ6r9ex0c1eOJX72eiQvY8eDlcQolqh"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJhFpUfIbtvUjCO15YjsuyN9PjFLgNegURfmGoyJjEOV"
  ];

  users.users.root.initialPassword = "admin";

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };
}
