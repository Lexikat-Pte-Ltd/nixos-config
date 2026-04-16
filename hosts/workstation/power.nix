# Power policy for limiting-factor: never sleep.
#
# This is a GPU workstation running long training/inference jobs. Unintended
# suspend mid-run is costly (wasted hours, half-written checkpoints, Docker
# containers in weird states). We enforce "always on" at two layers:
#
#   1. GNOME settings-daemon — stop it from ever *requesting* a suspend, and
#      make the Settings > Power panel reflect "Never" so the UI matches
#      reality.
#   2. systemd — mask the sleep/suspend/hibernate targets so nothing (not even
#      a misbehaving app calling `systemctl suspend` directly, and not even
#      logind's IdleAction) can transition the box into a low-power state.
#
# Poweroff and reboot are unaffected.
{ config, pkgs, lib, ... }:

{
  # ── Layer 1: GNOME ──────────────────────────────────────────────────────────
  # Merges with the dconf database in gui.nix via nix list concat.
  programs.dconf.profiles.user.databases = [{
    settings = {
      "org/gnome/settings-daemon/plugins/power" = {
        sleep-inactive-ac-type = "nothing";
        sleep-inactive-ac-timeout = lib.gvariant.mkUint32 0;
        sleep-inactive-battery-type = "nothing";
        sleep-inactive-battery-timeout = lib.gvariant.mkUint32 0;
        idle-dim = false;
      };
      "org/gnome/desktop/session" = {
        # 0 = never go idle. Screen lock is a separate setting (screensaver).
        idle-delay = lib.gvariant.mkUint32 0;
      };
    };
  }];

  # ── Layer 2: systemd ────────────────────────────────────────────────────────
  # Disabling the targets makes `systemctl suspend` (and any DBus call that
  # ultimately triggers them) a no-op.
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  # Logind: don't suspend on idle; ignore lid-switch (harmless on a desktop,
  # but belt-and-suspenders if this config ever runs on a laptop).
  services.logind.settings.Login = {
    IdleAction = "ignore";
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };
}
