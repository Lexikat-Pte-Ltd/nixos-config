# Akira's personal home-manager profile.
#
# Shared DX (dx.nix) and AI tools (ai-tools.nix) are applied automatically
# via sharedModules in flake.nix. This file adds personal config on top.
#
# The shared package set (packages.nix) already provides: nodejs, bun,
# docker, docker-compose, python, and common CLI tools. This profile adds
# a few extras for full-stack web development.
{ config, pkgs, lib, ... }:

{
  home = {
    username = "akira";
    homeDirectory = "/home/akira";
    packages = with pkgs; [
      pnpm
      typescript
    ];
  };

  programs = {
    # ── Git — identity ───────────────────────────────────────────────────
    # TODO: set your name and email
    git.settings = {
      user.name = "Akira";
      user.email = "akira@example.com";
      credential.helper = "${pkgs.gh}/bin/gh auth git-credential";
    };
  };
}
