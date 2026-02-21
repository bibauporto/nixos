{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-legacy.url = "github:NixOS/nixpkgs/nixos-24.11";

    impermanence.url = "github:nix-community/impermanence";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      ...
    }@inputs:
    {
      nixosConfigurations.lea-pc = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          (
            { pkgs, ... }:
            {
              nixpkgs.hostPlatform = "x86_64-linux";

              nixpkgs.overlays = [
                inputs.nix-cachyos-kernel.overlays.pinned
                (final: prev: {
                  stable = import inputs.nixpkgs-stable {
                    system = prev.stdenv.hostPlatform.system;
                    config.allowUnfree = true;
                  };
                })
                (final: prev: {
                  legacy = import inputs.nixpkgs-legacy {
                    system = prev.stdenv.hostPlatform.system;
                    config.allowUnfree = true;
                  };
                })
                (final: prev: {
                  microsoft-edge = prev.microsoft-edge.overrideAttrs (oldAttrs: rec {
                    version = "145.0.3800.70";
                    src = prev.fetchurl {
                      url = "https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/microsoft-edge-stable_${version}-1_amd64.deb";
                      hash = "sha256-gUyh9AD1ntnZb2iLRwKLxy0PxY0Dist73oT9AC2pFQI=";
                    };
                  });
                })
              ];

            }
          )

          inputs.impermanence.nixosModules.impermanence
          inputs.lanzaboote.nixosModules.lanzaboote

          ./configuration.nix
          ./module/core/cache-settings.nix
        ];
      };
    };
}
