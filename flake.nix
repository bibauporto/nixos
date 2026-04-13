{
  inputs = {
    # Primary: Small Unstable (faster CI/updates)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    # Secondary: Full Unstable
    # nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Secondary: Stable
    # nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";

    impermanence.url = "github:nix-community/impermanence";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.lea-pc = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [
              # Optional: CachyOS overlay (commented out as in original)
              # inputs.nix-cachyos-kernel.overlays.pinned

              # (final: prev: {
              #   # Access via pkgs.stable
              #   stable = import inputs.nixpkgs-stable {
              #     inherit system;
              #     config.allowUnfree = true;
              #   };
              #   # Access via pkgs.unstable (full branch)
              #   unstable = import inputs.nixpkgs-unstable {
              #     inherit system;
              #     config.allowUnfree = true;
              #   };
              # })
            ];
          }

          # External Modules
          inputs.impermanence.nixosModules.impermanence
          inputs.lanzaboote.nixosModules.lanzaboote
          inputs.home-manager.nixosModules.home-manager

          ./configuration.nix
        ];
      };
    };
}
