{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    neovim

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
      # Quick nixos commands
      nswitch = "sudo nixos-rebuild switch --flake #lea-pc";
      nbuild = "sudo nixos-rebuild build --flake .";
      ntest = "sudo nixos-rebuild test --flake .";
      nboot = "sudo nixos-rebuild boot --flake .";

      # Adding a few CachyOS-style basics to make the shell feel better
      ls = "ls --color=auto";
      ll = "ls -lh";
    };
  };

  users.users.LEA = {
    isNormalUser = true; # Required for standard user accounts
    extraGroups = [ "wheel" "networkmanager" "video" "input" "uinput" ];
    shell = pkgs.fish;
  };
}
