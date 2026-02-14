{ config, pkgs, lib, ... }:

{
  services.xserver.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # 1. Enable dconf
  programs.dconf.enable = true;

  # 2. Unlock Fractional Scaling for the User Session
  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/mutter" = {
          experimental-features = [ "scale-monitor-framebuffer" ];
        };
      };
    }
  ];

  # 3. Unlock Fractional Scaling for the Login Screen (GDM)
  # FIX: This must be a STRING formatted like a list for the INI file
  services.displayManager.gdm.settings = {
    "org/gnome/mutter" = {
      experimental-features = "['scale-monitor-framebuffer']";
    };
  };

  # 4. Force Wayland for crisp Electron apps
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  ##############################
  # GNOME Slimming
  ##############################
  services.gnome.core-apps.enable = false;
  documentation.doc.enable = false;
  services.gvfs.enable = true;

  environment.gnome.excludePackages = with pkgs; [
    epiphany geary gnome-maps gnome-music gnome-contacts gnome-weather gnome-tour
  ];

  environment.systemPackages = with pkgs; [
    nautilus gnome-console gnome-text-editor gnome-calculator loupe
    gnome-tweaks gnome-extensions-cli xclip
    gnomeExtensions.just-perfection
    gnomeExtensions.blur-my-shell
    gnomeExtensions.appindicator
  ];
}