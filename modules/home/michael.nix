# Michael's personal home-manager profile.
#
# Shared DX (dx.nix) and AI tools (ai-tools.nix) are applied automatically
# via sharedModules in flake.nix. This file adds personal config on top.
{ config, pkgs, lib, ... }:

{
  home = {
    username = "michael";
    homeDirectory = "/home/michael";
    packages = with pkgs; [
      neovim
      vscode
      rclone
    ];
  };

  programs = {
    # ── Git — identity ───────────────────────────────────────────────────
    # TODO: set your name and email
    git.settings = {
      user.name = "Michael";
      user.email = "michael@example.com";
      credential.helper = "${pkgs.gh}/bin/gh auth git-credential";
    };
  };
}
