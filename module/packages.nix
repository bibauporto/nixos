{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    gcc       # The compiler
    gnumake   # The build orchestrator
    unzip     # To unpack Mason/Lazy downloads
    fd


    # Apps
    btop

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
    antigravity 
    
    # Required for your fish config
    fastfetch
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

  users.users.LEA = {
    isNormalUser = true; 
    extraGroups = [ "wheel" "networkmanager" "video" "input" "uinput" ];
    shell = pkgs.fish;
  };
}
