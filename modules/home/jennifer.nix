# Jennifer's personal home-manager profile.
#
# Shared DX (dx.nix) and AI tools (ai-tools.nix) are applied automatically
# via sharedModules in flake.nix. This file adds personal config on top.
{ config, pkgs, lib, ... }:

{
  home = {
    username = "jennifer";
    homeDirectory = "/home/jennifer";
    packages = with pkgs; [
      windsurf
    ];
  };

  programs = {
    # ── Git — identity ───────────────────────────────────────────────────
    # TODO: set your name and email
    git.settings = {
      user.name = "Jennifer";
      user.email = "jennifer@example.com";
      credential.helper = "${pkgs.gh}/bin/gh auth git-credential";
    };
  };
}
