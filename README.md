# nixos-config

NixOS configurations for **limiting-factor**, a dual RTX 4090 GPU workstation. The machine runs GNOME with tiling window management and is primarily accessed remotely via Tailscale.

## Configurations

| Name              | Command                                          | Purpose                                                                                                 |
| ----------------- | ------------------------------------------------ | ------------------------------------------------------------------------------------------------------- |
| `bootstrap`       | `nixos-rebuild switch --flake .#bootstrap`       | Minimal config for initial setup and emergency/debug use. SSH + Tailscale + CLI tools. No GUI, no CUDA. |
| `limiting-factor` | `nixos-rebuild switch --flake .#limiting-factor` | Full workstation. GNOME + Pop Shell tiling, NVIDIA drivers, CUDA, Docker with GPU passthrough.          |

## Layout

```
flake.nix
hardware-configuration.nix      # generated on target — see Setup
hosts/
  bootstrap/                     # minimal system config
  workstation/                   # full config (imports gpu.nix, gui.nix)
modules/
  common/                        # machine-level: nix settings, users, packages, SSH/Tailscale
  home/
    dx.nix                       # shared DX: zsh, vim, tmux, kitty, git defaults, CLI tools
    ai-tools.nix                 # shared: populates ~/.config/opencode and ~/.claude
    ai-tools/                    # default AI tool configs (see AI Tools below)
    elijah.nix                   # personal: git identity, dotfiles symlinks
```

## Setup

1. Boot the NixOS installer on the target machine.
2. Partition disks and install NixOS.
3. Generate and replace the hardware config:

   ```bash
   nixos-generate-config --show-hardware-config > hardware-configuration.nix
   ```

4. Import it in `hosts/bootstrap/default.nix` and `hosts/workstation/default.nix`:

   ```nix
   imports = [ ... ../../hardware-configuration.nix ];
   ```

5. Build the bootstrap config first, then switch to the full workstation once stable.

## Remote access

Primary access is via [Tailscale](https://tailscale.com/). SSH is enabled with authorized keys and password authentication for now. Authorized keys are managed in `modules/common/users.nix`, and SSH/Tailscale settings live in `modules/common/remote-access.nix`.

## Adding users

1. Add your system user to `modules/common/users.nix` (groups, shell, SSH keys).
2. Create `modules/home/<you>.nix` — see `elijah.nix` as a template. It imports the shared DX layer (`dx.nix`) and adds your personal config (git identity, dotfiles, etc.).
3. Register your profile in `flake.nix` under `hmUsers`.

## GPU

The workstation config (`limiting-factor`) enables:

- NVIDIA proprietary drivers with modesetting
- CUDA toolkit (system-wide)
- NVIDIA container toolkit for Docker GPU passthrough (CDI)
- `nvtop` for GPU monitoring

## AI Tools

`ai-tools.nix` is a shared module (like `dx.nix`) that configures [OpenCode](https://opencode.ai) and [Claude Code](https://claude.ai/code) for every user. It runs during `nixos-rebuild switch` and populates each user's `~/.config/opencode/` and `~/.claude/` via symlinks.

### How config resolution works

For each config file, the activation script checks two locations **in order**:

1. **`~/dotfiles/ai-tools/`** — personal overrides (per-user, since `$HOME` differs)
2. **`modules/home/ai-tools/`** — in-repo defaults (shared, read-only fallback)

The first match wins. If neither exists for a given file, it is silently skipped.

This means:
- **Out of the box**, every user gets the in-repo defaults (minimal placeholders).
- **To customise**, create `~/dotfiles/ai-tools/` mirroring the structure below and add your own configs. Only the files you provide will override; everything else falls back to the in-repo defaults.

### Directory structure

```
ai-tools/
├── shared/
│   ├── AI.md              # instructions shared by both tools
│   └── skills/            # skill definitions (symlinked into both tools)
├── opencode/
│   ├── opencode.json      # model/provider config (dotfiles only)
│   ├── AGENTS.md          # concatenated after shared/AI.md
│   ├── agents/            # agent definitions
│   └── commands/          # slash commands (dotfiles only)
└── claude-code/
    ├── settings.json      # Claude Code settings (dotfiles only)
    ├── CLAUDE.md          # concatenated after shared/AI.md
    └── agents/            # agent definitions
```

Files marked *(dotfiles only)* are not shipped in the in-repo defaults — they only activate if present in your `~/dotfiles/ai-tools/`.

## Additional configs

`dx.nix` is the shared DX layer. All users are encouraged to bring their own configs!

You can set symlinks to overwrite/control global configs (e.g. .claude) using these configs, orchestrated via Home Manager.
