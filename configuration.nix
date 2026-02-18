{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./module/core/filesystem.nix
    ./module/core/boot.nix
    ./module/hardware/keyboard.nix
    ./module/core/persistence.nix
    ./module/desktop/desktop.nix
    ./module/programs/packages.nix
    ./module/hardware/kanata.nix
    ./module/programs/rclone.nix
    ./module/core/network.nix
    ./module/core/gc.nix
    ./module/programs/nvim.nix
    ./module/desktop/fonts.nix
    ./module/libs/libraries.nix
  ];

  # Nix Settings
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # For newer Zenbooks (Broadwell+)
      intel-vaapi-driver # For older Intel graphics
      libvdpau-va-gl
    ];
  };

  # User Configuration
  users.mutableUsers = false;
  users.users.LEA = {
    isNormalUser = true;
    description = "LEA";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "input"
      "uinput"
      "docker"
    ];
    shell = pkgs.fish;
    # Using your existing hashed password
    hashedPassword = "$6$duZBUtU4Y1zhdPJ7$zaSbKAIRbGfDIRxeCzv1BjfmrGCIQiwAFdzn13BWv1fb/L2Sp2DGfe69JKynD4eLf8pB85GPLRwRT4ErIj5k41";
  };

  programs.fuse.userAllowOther = true;

  # System version
  system.stateVersion = "25.11";
}
