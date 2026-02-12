{ config, pkgs, ... }:

{
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  
  # Optional: Optimizes the store by hard-linking duplicate files
  nix.settings.auto-optimise-store = true;
}
