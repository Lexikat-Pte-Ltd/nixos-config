# Shared developer experience — imported as a sharedModule for every user.
# Provides: zsh with sensible defaults, git best-practices, basic vim/tmux/kitty,
# direnv for per-project environments, and the shared CLI package set.
#
# Intentionally leaves git user.name / user.email unset — each user sets their
# own identity in their personal profile.
#
# Subjective preferences (themes, keybindings, prompt themes) belong in
# individual user profiles, not here.
{ config, pkgs, lib, ... }:

{
  home = {
    enableNixpkgsReleaseCheck = false;
    packages = import ../common/packages.nix { inherit pkgs; };
    stateVersion = "24.11";
  };

  programs = {
    # ── Zsh ──────────────────────────────────────────────────────────────
    zsh = {
      enable = true;
      autocd = false;

      initContent = ''
        if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
          . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
          . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
        fi

        export PATH=$HOME/.pnpm-packages/bin:$HOME/.pnpm-packages:$PATH
        export PATH=$HOME/.npm-packages/bin:$HOME/bin:$PATH
        export PATH=$HOME/.local/share/bin:$PATH

        export HISTIGNORE="pwd:ls:cd"

        export ALTERNATE_EDITOR=""
        export EDITOR="vim"
        export VISUAL="vim"

        # Nix helpers
        shell() {
            nix-shell '<nixpkgs>' -A "$1"
        }

        # Aliases — objective improvements on defaults
        alias diff=difft
        alias ls="eza --group --icons";
        alias ll="eza -la --group --git --icons";
        alias la="eza -a --group --icons";
        alias lt="eza -T --level=2 --git-ignore --icons";
        alias tree="eza -T --icons";
        alias tmux-reset="tmux kill-server 2>/dev/null; rm -rf ~/.cache/tmux/resurrect/*; tmux";

        # GPU monitoring
        alias gpu="nvidia-smi"
        alias watch-gpu="watch -n1 nvidia-smi"

        # zoxide
        eval "$(zoxide init zsh)"

        # atuin
        if command -v atuin >/dev/null 2>&1; then
          eval "$(atuin init zsh)"
        fi
      '';
    };

    # ── Git (shared defaults — no identity) ──────────────────────────────
    git = {
      enable = true;
      ignores = [ "*.swp" ];
      lfs.enable = true;
      signing.format = null;
      settings = {
        init.defaultBranch = "main";
        core = {
          editor = "vim";
          autocrlf = "input";
        };
        pull.rebase = true;
        rebase.autoStash = true;
        diff.external = "${pkgs.difftastic}/bin/difft";
        pager.diff = "";
        pager.show = "";
      };
    };

    # ── Vim (functional baseline — no themes or custom keybindings) ──────
    vim = {
      enable = true;
      settings = { ignorecase = true; };
      extraConfig = ''
        set number
        set history=1000
        set nocompatible
        set modelines=0
        set encoding=utf-8
        set scrolloff=3
        set showmode
        set showcmd
        set hidden
        set wildmenu
        set wildmode=list:longest
        set cursorline
        set ttyfast
        set nowrap
        set ruler
        set backspace=indent,eol,start
        set laststatus=2
        set clipboard=autoselect
        set nobackup
        set nowritebackup
        set noswapfile
        set tabstop=8
        set shiftwidth=4
        set softtabstop=4
        set expandtab
        set incsearch
        set gdefault
        syntax on
        filetype on
        filetype plugin on
        filetype indent on
      '';
    };

    # ── SSH ───────────────────────────────────────────────────────────────
    ssh = {
      enable = true;
      matchBlocks = {
        "*" = {
          serverAliveInterval = 60;
          serverAliveCountMax = 30;
        };
      };
    };

    # ── Tmux (functional baseline — no theme or custom keybindings) ──────
    tmux = {
      enable = true;
      plugins = with pkgs.tmuxPlugins; [
        sensible
        yank
        {
          plugin = resurrect;
          extraConfig = ''
            set -g @resurrect-dir '$HOME/.cache/tmux/resurrect'
            set -g @resurrect-capture-pane-contents 'on'
            set -g @resurrect-pane-contents-area 'visible'
          '';
        }
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '5'
          '';
        }
      ];
      terminal = "screen-256color";
      escapeTime = 10;
      historyLimit = 50000;
      extraConfig = ''
        set -g focus-events on
        set -g allow-passthrough on
        set -g set-titles on
        set -g set-titles-string "#{session_name}:#{window_index}.#{pane_index} #{pane_current_command} #{pane_title} #{pane_current_path}"
        set -g mouse on
      '';
    };

    # ── Kitty (functional baseline — no theme or custom keybindings) ─────
    kitty = {
      enable = true;
      font = {
        name = "MesloLGS NF";
        size = lib.mkDefault 12;
      };
      settings = {
        enable_audio_bell = "no";
        allow_remote_control = "socket-only";
        listen_on = "unix:/tmp/mykitty";
        scrollback_lines = 10000;
        wheel_scroll_multiplier = 3.0;
        shell_integration = "enabled";
        allow_hyperlinks = "yes";
        allow_cloning = "ask";
      };
    };

    # ── Direnv (per-project Nix environments) ────────────────────────────
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

  };
}
