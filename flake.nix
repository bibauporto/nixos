{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
    { self, nixpkgs, ... }@inputs:
    {
      nixosConfigurations.lea-pc = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          (
            { pkgs, ... }:
            {
              nixpkgs.hostPlatform = "x86_64-linux";

              # 1. Apply the CachyOS Overlay
              nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];

              # 2. Configure the Kernel
              # Choose 'latest', 'lts', or a specific variant like 'bore'
              boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

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
