{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    # Misc
    unzip
    openssl_3

    # Apps
    btop
    #wpsoffice
    #onlyoffice-desktopeditors
    #antigravity
    vlc
    stable.stremio

    # Version Control & Cloud
    gh
    rclone

    # Browsers
    stable.microsoft-edge

    # Development
    vscode
    opencode
    go
    bun
    nodejs_25
    lazygit
    ripgrep
    fd
    fzf
    luarocks
    tree-sitter
    gcc
    gnumake
    cargo

    # Required for your fish config
    fastfetch

    # Nix
    nixfmt
    nixd
    direnv
  ];

  services.flatpak.enable = true;

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

  virtualisation.docker.enable = true;
}
