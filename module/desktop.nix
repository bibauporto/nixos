{ config, pkgs, lib, ... }:

{
  services.xserver.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ]; # Start clean, no XTerm
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
    nautilus          
    gnome-console      
    gnome-text-editor   
    gnome-calculator    
    loupe               # Image Viewer
    
    # System Tools
    gnome-tweaks
    gnome-extensions-cli
    xclip 
    
    # Extensions
    gnomeExtensions.just-perfection    
    gnomeExtensions.blur-my-shell
    gnomeExtensions.appindicator # Helpful for background apps like rclone/discord
  ];
}
