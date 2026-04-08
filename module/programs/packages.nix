{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    ### --- System & CLI Utilities --- ###
    btop
    unzip
    fastfetch       # Required for your fish config
    ripgrep # Recursive search
    fd # Find files
    fzf # Fuzzy finder
    direnv # For auto-loading .env files

    ### --- Cloud & Storage --- ###
    rclone

    ### --- Browsers & Communication --- ###
    google-chrome

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
    openssl_3       # prisma-engines_7 needs openssl_3

    ### --- Nix Ecosystem --- ###
    nixfmt
    nixd

    ### --- Media & Graphics --- ###
    vlc
    stremio-linux-shell
    pinta
    pcsx2

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

      if status is-interactive
        fastfetch       # Show system info on startup 
      end
    '';

    shellAliases = {
      nswitch = "sudo nixos-rebuild switch --flake #lea-pc";
      nbuild = "sudo nixos-rebuild build --flake .";
      ntest = "sudo nixos-rebuild test --flake .";
      nboot = "sudo nixos-rebuild boot --flake .";
      nupdate = "nix flake update";
      nlist = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      ntmp = "sudo du -hx / --max-depth=5";
      ndel = "sudo nix-collect-garbage -d";

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