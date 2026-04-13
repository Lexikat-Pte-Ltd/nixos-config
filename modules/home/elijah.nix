# Elijah's personal home-manager profile.
# Imports the shared DX layer and adds: git identity, dotfiles symlinks,
# AI tool configs, and SSH settings.
#
# Other users: copy this file, change the username/identity, and remove the
# parts you don't need. Register your profile in flake.nix under hmUsers.
{ config, pkgs, lib, ... }:

let
  dx = import ./dx.nix { inherit config pkgs lib; };
in
{
  imports = [ ./ai-tools.nix ];

  home = {
    username = "elijah";
    homeDirectory = "/home/elijah";
    packages = dx.home.packages;
    stateVersion = dx.home.stateVersion;

    # Symlink dotfiles-managed configs
    activation.linkDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      DOTFILES_DIR="$HOME/dotfiles"

      link_config() {
        local src="$1"
        local dest="$2"
        if [ -e "$src" ]; then
          if [ -e "$dest" ] || [ -L "$dest" ]; then
            rm -rf "$dest"
          fi
          mkdir -p "$(dirname "$dest")"
          ln -sf "$src" "$dest"
          echo "Linked: $src -> $dest"
        else
          echo "Warning: Source not found, skipping: $src"
        fi
      }

      link_config "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
    '';
  };

  programs = lib.recursiveUpdate dx.programs {
    # Git identity
    git.settings = {
      user.name = "0xEljh";
      user.email = "elijahng96@gmail.com";
      credential.helper = "${pkgs.gh}/bin/gh auth git-credential";
    };

    # SSH — include external config if present
    ssh = {
      enableDefaultConfig = false;
      includes = [
        "${config.home.homeDirectory}/.ssh/config_external"
      ];
    };
  };
}
