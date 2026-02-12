{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    neovim
    gcc       # The compiler
    gnumake   # The build orchestrator
    unzip     # To unpack Mason/Lazy downloads

    # Version Control & Cloud
    git
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

      
      ls = "ls --color=auto";
      ll = "ls -lh";
    };
  };

  users.users.LEA = {
    isNormalUser = true; 
    extraGroups = [ "wheel" "networkmanager" "video" "input" "uinput" ];
    shell = pkgs.fish;
  };
}
