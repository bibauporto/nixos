{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    impermanence.url = "github:nix-community/impermanence";
    
    # nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  outputs = { self, nixpkgs, impermanence, ... }: {
  # outputs = { self, nixpkgs, impermanence, nix-cachyos-kernel, ... }: {
    nixosConfigurations.lea-pc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
   
      # specialArgs = { inherit nix-cachyos-kernel; }; 
      modules = [ 
        ./configuration.nix 
        impermanence.nixosModules.impermanence 
      ];
    };
  };
}
