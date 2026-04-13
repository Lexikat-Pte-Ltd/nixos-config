# CLI tools and development packages shared across both configurations.
# Referenced from ~/dotfiles/nixos-config/modules/shared/packages.nix
{ pkgs }:

with pkgs; [
  # Shell and terminal
  bash-completion
  bat
  btop
  coreutils
  eza
  fd
  fzf
  jq
  killall
  fastfetch
  nushell
  ouch
  ripgrep
  tmux
  tree
  unzip
  zip
  zoxide
  atuin
  difftastic
  zsh-powerlevel10k
  lazygit

  # Encryption and security
  age
  gnupg
  magic-wormhole
  openssh

  # Git
  gh

  # Cloud / containers
  docker
  docker-compose

  # Node.js / JS
  nodejs_24
  bun

  # C / C++
  gcc
  gnumake
  cmake

  # Lua (for neovim plugins)
  lua5_1
  luarocks

  # Python
  python3
  uv
  ruff
  pyright

  # Image processing (image.nvim)
  imagemagick

  # Media
  ffmpeg

  # Fonts (user-level)
  meslo-lgs-nf
  noto-fonts
  noto-fonts-color-emoji

  # Misc dev tools
  direnv
  sqlite
  wget
  kitty
]
