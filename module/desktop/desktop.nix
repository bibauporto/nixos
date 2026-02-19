{
  pkgs,
  ...
}:

let
  wallpaperPath = ./. + "/wallpaper.jpg";
in
{
  services.xserver.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Disable sudo lecture
  security.sudo.extraConfig = ''
    Defaults lecture=never
  '';

  # 1. Enable dconf
  programs.dconf.enable = true;
  
  # 2. GNOME Declarative Configuration
  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/mutter" = {
          experimental-features = [ "scale-monitor-framebuffer" ];
        };

        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
        "org/gnome/desktop/wm/preferences" = {
          button-layout = "appmenu:minimize,maximize,close";
        };

        "org/gnome/desktop/background" = {
          picture-uri = "file://${wallpaperPath}";
          picture-uri-dark = "file://${wallpaperPath}";
          picture-options = "zoom";
        };
        "org/gnome/desktop/screensaver" = {
          picture-uri = "file://${wallpaperPath}";
        };

        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = [
            "just-perfection-desktop@just-perfection"
            "blur-my-shell@aunetx"
          ];
        };
      };
    }
  ];

  # 3. Unlock Fractional Scaling for the Login Screen (GDM)
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
    epiphany
    geary
    gnome-maps
    gnome-music
    gnome-contacts
    gnome-weather
    gnome-tour
  ];

  environment.systemPackages = with pkgs; [
    nautilus
    gnome-text-editor
    gnome-console
    gnome-calculator
    loupe
    gnome-tweaks
    gnome-extensions-cli
    xclip
    gnomeExtensions.just-perfection
    gnomeExtensions.blur-my-shell
  ];
}
