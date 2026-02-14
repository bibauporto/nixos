{
  config,
  pkgs,
  lib,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    # Support
    unzip

    # Apps
    btop
    wpsoffice
    antigravity

    # Version Control & Cloud
    gh
    rclone

    # Browsers
    microsoft-edge

    # Development
    vscode
    opencode
    go
    bun
    nodejs_25
    openssl_3

    # Required for your fish config
    fastfetch

    # Nix
    nixfmt
    direnv
  ];

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
      # Optional: Good for modern Git repos
      init.defaultBranch = "main";
      # Automatically handle some line ending issues
      core.autocrlf = "input";
    };
  };

  virtualisation.docker.enable = true;

  users.users.LEA = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "input"
      "uinput"
      "docker"
    ];
    shell = pkgs.fish;
  };
}
