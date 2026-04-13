{
  description = "NixOS configurations for limiting-factor (GPU workstation)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager } @inputs:
    let
      system = "x86_64-linux";
      user = "elijah";

      # Common home-manager setup shared by both configurations
      hmModule = {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";
          overwriteBackup = true;
          users.${user} = import ./modules/home;
        };
      };
    in
    {
      nixosConfigurations = {
        # ── Bootstrap ──────────────────────────────────────────────────────
        # Minimal config for initial NixOS install and emergency/debug use.
        # No GUI, no CUDA — fast to evaluate and small closure.
        #   nixos-rebuild switch --flake .#bootstrap
        bootstrap = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = inputs;
          modules = [
            home-manager.nixosModules.home-manager
            hmModule
            ./hosts/bootstrap
          ];
        };

        # ── Full workstation ───────────────────────────────────────────────
        # GNOME + Pop Shell tiling, 2x RTX 4090, CUDA, Docker GPU passthrough.
        #   nixos-rebuild switch --flake .#limiting-factor
        limiting-factor = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = inputs;
          modules = [
            home-manager.nixosModules.home-manager
            hmModule
            ./hosts/workstation
          ];
        };
      };

      # Dev shell for working on this config
      devShells.${system}.default = let
        pkgs = nixpkgs.legacyPackages.${system};
      in pkgs.mkShell {
        nativeBuildInputs = with pkgs; [ git ];
      };
    };
}
