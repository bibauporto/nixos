{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    impermanence.url = "github:nix-community/impermanence";
  };
  outputs = { self, nixpkgs, impermanence, ... }: {
    nixosConfigurations.lea-pc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix impermanence.nixosModules.impermanence ];
    };
  };
}
