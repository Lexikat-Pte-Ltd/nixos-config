# PLACEHOLDER — replace with the output of nixos-generate-config on the target device.
#
# After installing NixOS on limiting-factor, run:
#   sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
#
# Then import it in both hosts/bootstrap/default.nix and hosts/workstation/default.nix:
#   imports = [ ... ../../hardware-configuration.nix ];
#
# This file is intentionally NOT imported by default so the flake evaluates
# cleanly on any machine before the target hardware is available.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # These will be filled in by nixos-generate-config:
  # boot.initrd.availableKernelModules = [ ... ];
  # boot.kernelModules = [ ... ];
  # fileSystems."/" = { ... };
  # fileSystems."/boot" = { ... };
  # swapDevices = [ ... ];
}
