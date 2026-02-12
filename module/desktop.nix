{ config, pkgs, lib, ... }:

{
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Strips GNOME down to the basics
  services.gnome.core-apps.enable = false;

  # Ensure Nautilus can handle file operations/trash/mounting
  services.gvfs.enable = true;

  environment.gnome.excludePackages = with pkgs; [
    epiphany      # Browser
    geary         # Email
    gnome-maps
    gnome-music
    gnome-contacts
    gnome-weather
    gnome-tour
  ];

  environment.systemPackages = with pkgs; [
    # --- The "Normal" GNOME Apps ---
    nautilus            # File Manager
    gnome-console       # Modern Terminal
    gnome-text-editor   # This is the "normal" text editor you are looking for
    gnome-calculator    # Usually handy to keep
    
    # System Tools
    gnome-tweaks
    gnome-extensions-cli
    
    # Extensions
    gnomeExtensions.just-perfection    
    gnomeExtensions.blur-my-shell
    gnomeExtensions.appindicator # Helpful for background apps like rclone/discord
  ];
}