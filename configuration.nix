{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./module/filesystem.nix
    ./module/boot.nix         
    ./module/keyboard.nix
    ./module/persistence.nix
    ./module/desktop.nix
    ./module/packages.nix
    ./module/kanata.nix
    ./module/rclone.nix
    ./module/network.nix
    ./module/gc.nix   
    ./module/libraries.nix
  ];

  # Nix Settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # User Configuration
  users.mutableUsers = false;
  users.users.LEA = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    # Using your existing hashed password
    hashedPassword = "$6$duZBUtU4Y1zhdPJ7$zaSbKAIRbGfDIRxeCzv1BjfmrGCIQiwAFdzn13BWv1fb/L2Sp2DGfe69JKynD4eLf8pB85GPLRwRT4ErIj5k41";
  };

  programs.fuse.userAllowOther = true;

  # System version
  system.stateVersion = "25.11"; 
}
