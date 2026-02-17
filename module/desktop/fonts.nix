{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    corefonts # Standard MS fonts
    vista-fonts # Calibri, Consolas, etc.
  ];
}
