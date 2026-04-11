{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    ### --- System & CLI Utilities --- ###
    btop
    unzip
    fastfetch # Required for your fish config
    ripgrep # Recursive search
    fd # Find files
    fzf # Fuzzy finder
    direnv # For auto-loading .env files

    ### --- Cloud & Storage --- ###
    rclone

    ### --- Browsers & Communication --- ###
    brave

    ### --- Development Tools --- ###
    vscode
    gh
    opencode
    lazygit

    # Programming Languages & Runtimes
    go
    bun
    nodejs_25
    cargo
    rustc
    luarocks

    # Build Tools & Dependencies
    gcc
    gnumake
    tree-sitter
    antigravity
    prisma-engines_7
    openssl_3 # prisma-engines_7 needs openssl_3

    ### --- Nix Ecosystem --- ###
    nixfmt
    nixd

    ### --- Media & Graphics --- ###
    vlc
    stremio-linux-shell
    pinta
    pcsx2
    inkscape

    ### --- Productivity --- ###
    onlyoffice-desktopeditors
    # wpsoffice

    ### --- Disabled / Reference --- ###
    # bitwarden-desktop
  ];

  ### --- Shell Configuration --- ###
  # All fish settings must be inside this block
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set fish_greeting # Disable greeting

      function _run
          set_color yellow
          echo "➜ $argv"
          set_color normal
          eval $argv
      end

      function nswitch; _run sudo nixos-rebuild switch --flake .#lea-pc; end
      function nbuild;  _run sudo nixos-rebuild build --flake .; end
      function ntest;   _run sudo nixos-rebuild test --flake .; end
      function nboot;   _run sudo nixos-rebuild boot --flake .; end
      function nupdate; _run sudo nix flake update; end
      function nlist;   _run sudo nix-env --list-generations --profile /nix/var/nix/profiles/system; end
      function ntmp;    _run sudo du -hx / --max-depth=5; end
      function ndel;    _run sudo nix-collect-garbage -d; end

      if status is-interactive
        fastfetch       # Show system info on startup 
      end
    '';

    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -lh";
    };
  };

  ### --- Version Control --- ###
  programs.git = {
    enable = true;
    config = {
      user = {
        name = "bibauporto";
        email = "pedroleal2651@gmail.com";
      };
      init.defaultBranch = "main";
      core.autocrlf = "input";
    };
  };

  ### --- Gaming --- ###
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  ### --- Virtualization & Services --- ###
  virtualisation.docker.enable = true;

  # Flatpak
  # services.flatpak.enable = true;
}
