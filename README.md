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
    elijah.nix                   # personal: git identity, dotfiles symlinks, ai-tools
    ai-tools.nix                 # helper to setup ai related global configs
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

## Additional configs

`dx.nix` is the shared DX layer. All users are encouraged to bring their own configs!

You can set symlinks to overwrite/control global configs (e.g. .claude) using these configs, orchestrated via Home Manager.
