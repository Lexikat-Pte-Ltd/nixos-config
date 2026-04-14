# Shared developer experience — imported by every user's home-manager profile.
# Provides: zsh + powerlevel10k, sensible git defaults, vim, tmux, kitty,
# and the shared CLI package set.
#
# Intentionally leaves git user.name / user.email unset — each user sets their
# own identity in their personal profile via lib.recursiveUpdate or programs.git.settings.
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
      plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
      ];

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

        # Aliases
        alias diff=difft
        alias ls="eza --group --icons";
        alias ll="eza -la --group --git --icons";
        alias la="eza -a --group --icons";
        alias lt="eza -T --level=2 --git-ignore --icons";
        alias tree="eza -T --icons";
        alias tmux-reset="tmux kill-server 2>/dev/null; rm -rf ~/.cache/tmux/resurrect/*; tmux";

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

    # ── Vim ──────────────────────────────────────────────────────────────
    vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        vim-airline
        vim-airline-themes
        vim-startify
        vim-tmux-navigator
      ];
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
        set relativenumber
        set rnu
        set tabstop=8
        set shiftwidth=2
        set softtabstop=2
        set expandtab
        set incsearch
        set gdefault
        syntax on
        filetype on
        filetype plugin on
        filetype indent on
        let g:airline_theme='bubblegum'
        let g:airline_powerline_fonts = 1
        let mapleader=","
        let maplocalleader=" "
        nnoremap j gj
        nnoremap k gk
        nnoremap <leader>q :q<cr>
        nnoremap <C-h> <C-w>h
        nnoremap <C-j> <C-w>j
        nnoremap <C-k> <C-w>k
        nnoremap <C-l> <C-w>l
        nnoremap Y y$
        nnoremap <tab> :bnext<cr>
        nnoremap <S-tab> :bprev<cr>
        cmap w!! w !sudo tee % >/dev/null
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

    # ── Tmux ─────────────────────────────────────────────────────────────
    tmux = {
      enable = true;
      plugins = with pkgs.tmuxPlugins; [
        vim-tmux-navigator
        sensible
        yank
        prefix-highlight
        {
          plugin = power-theme;
          extraConfig = ''
            set -g @tmux_power_theme 'gold'
          '';
        }
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
      prefix = "C-x";
      escapeTime = 10;
      historyLimit = 50000;
      extraConfig = ''
        set -g focus-events on
        set -g allow-passthrough on
        set -g set-titles on
        set -g set-titles-string "#{session_name}:#{window_index}.#{pane_index} #{pane_current_command} #{pane_title} #{pane_current_path}"
        set -g prefix2 C-b
        set -g mouse on

        unbind '"'
        unbind %

        bind-key -T prefix C-b send-prefix -2
        bind-key x split-window -v
        bind-key v split-window -h

        bind-key -n M-k select-pane -U
        bind-key -n M-h select-pane -L
        bind-key -n M-j select-pane -D
        bind-key -n M-l select-pane -R

        is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
        bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
        bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
        bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
        bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
        tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
        if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
        if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

        bind-key -T copy-mode-vi 'C-h' select-pane -L
        bind-key -T copy-mode-vi 'C-j' select-pane -D
        bind-key -T copy-mode-vi 'C-k' select-pane -U
        bind-key -T copy-mode-vi 'C-l' select-pane -R
        bind-key -T copy-mode-vi 'C-\\' select-pane -l

        set -s extended-keys on
        set -s user-keys[0] "\x1b[13;2u"
        bind-key -n User0 send-keys Escape "[13;2u"

        set -g @yank_action 'copy-pipe-no-clear'
        bind -T copy-mode MouseDown1Pane select-pane \; send-keys -X clear-selection
        bind -T copy-mode-vi MouseDown1Pane select-pane \; send-keys -X clear-selection
        bind -T copy-mode DoubleClick1Pane select-pane \; send-keys -X select-word \; send-keys -X copy-pipe-no-clear
        bind -T copy-mode-vi DoubleClick1Pane select-pane \; send-keys -X select-word \; send-keys -X copy-pipe-no-clear
        bind -n DoubleClick1Pane select-pane \; copy-mode -M \; send-keys -X select-word \; send-keys -X copy-pipe-no-clear
        bind -T copy-mode TripleClick1Pane select-pane \; send-keys -X select-line \; send-keys -X copy-pipe-no-clear
        bind -T copy-mode-vi TripleClick1Pane select-pane \; send-keys -X select-line \; send-keys -X copy-pipe-no-clear
        bind -n TripleClick1Pane select-pane \; copy-mode -M \; send-keys -X select-line \; send-keys -X copy-pipe-no-clear
        bind-key M-r run-shell "rm -rf $HOME/.cache/tmux/resurrect/*" \; display-message "Resurrect data cleared"
      '';
    };

    # ── Kitty ────────────────────────────────────────────────────────────
    kitty = {
      enable = true;
      font = {
        name = "MesloLGS NF";
        size = lib.mkDefault 12;
      };
      themeFile = "Catppuccin-Mocha";
      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = "no";
        allow_remote_control = "socket-only";
        listen_on = "unix:/tmp/mykitty";
        scrollback_lines = 10000;
        wheel_scroll_multiplier = 3.0;
        shell_integration = "enabled";
        allow_hyperlinks = "yes";
        allow_cloning = "ask";
        background_opacity = "0.90";
        window_padding_width = 8;
        inactive_text_alpha = "0.80";
        inactive_border_color = "#1e1e2e";
        active_border_color = "#cba6f7";
        tab_bar_edge = "top";
        tab_bar_min_tabs = 2;
        tab_title_template = "{index}:{title}";
        active_tab_foreground = "#1e1e2e";
        active_tab_background = "#a6e3a1";
      };
      keybindings = {
        "ctrl+shift+enter" = "new_os_window_with_cwd";
        "ctrl+shift+t" = "new_tab_with_cwd";
        "alt+h" = "neighbor left";
        "alt+l" = "neighbor right";
        "alt+k" = "neighbor up";
        "alt+j" = "neighbor down";
        "ctrl+]" = "next_tab";
        "ctrl+[" = "previous_tab";
        "ctrl+shift+c" = "copy_to_clipboard";
        "ctrl+shift+v" = "paste_from_clipboard";
        "shift+enter" = "send_text all \\x1b[13;2u";
      };
    };

  };
}
