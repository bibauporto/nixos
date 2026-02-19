{ ... }:

{
  home-manager.users.LEA = { pkgs, ... }: { 
    programs.alacritty = {
      enable = true;
      settings = {
        window.startup_mode = "Fullscreen";
        colors = {
          primary = {
            background = "#000000";
            foreground = "#abb2bf";
          };
          normal = {
            black = "#000000";
            red = "#e40101";
            green = "#5DB844";
            yellow = "#e6ed5a";
            blue = "#79C0FF";
            magenta = "#b180d7";
            cyan = "#00AAAA";
            white = "#cccccc";
          };
          bright = {
            black = "#525252";
            red = "#e40101";
            green = "#5DB844";
            yellow = "#e6ed5a";
            blue = "#A5D6FF";
            magenta = "#b180d7";
            cyan = "#00AAAA";
            white = "#fcfcfc";
          };
        };
      };
    };

    
    dconf.settings = {
      "org/gnome/desktop/applications/terminal" = {
        exec = "alacritty";
      };
    };

    
    home.sessionVariables = {
      TERMINAL = "alacritty";
    };
  };
}
