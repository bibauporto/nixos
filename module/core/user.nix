{ pkgs, ... }:
{
  # User Configuration
  users.mutableUsers = false;
  users.users.lea = {
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
}
