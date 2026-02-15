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

    nixos-stable.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-stable,
      ...
    }@inputs:
    {
      nixosConfigurations.lea-pc = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };

        modules = [
          { nixpkgs.hostPlatform = "x86_64-linux"; }

          inputs.impermanence.nixosModules.impermanence
          inputs.lanzaboote.nixosModules.lanzaboote

          ./configuration.nix
          ./module/cache-settings.nix
        ];
      };
    };
}
