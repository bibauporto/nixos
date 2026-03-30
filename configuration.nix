{
  ...
}:

{
  imports = [
    ./hardware-configuration.nix

    # Core
    ./module/core/boot.nix
    ./module/core/cache.nix
    ./module/core/filesystem.nix
    ./module/core/gc.nix
    ./module/core/network.nix
    ./module/core/nix-ld.nix
    ./module/core/nix.nix
    ./module/core/persistence.nix
    ./module/core/user.nix

    # Hardware
    ./module/hardware/graphics.nix
    ./module/hardware/kanata.nix
    ./module/hardware/keyboard.nix

    # Desktop
    ./module/desktop/fonts.nix
    ./module/desktop/gnome.nix

    # Programs
    ./module/programs/alacritty.nix
    ./module/programs/nvim.nix
    ./module/programs/packages.nix
    ./module/programs/rclone.nix
  ];

  # System version
  system.stateVersion = "25.11";
}
