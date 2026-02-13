  programs.neovim = {
  enable = true;
  plugins = with pkgs.vimPlugins; [
    telescope-nvim
    plenary-nvim  # Essential dependency
  ];
  extraLuaConfig = ''
    require('telescope').setup{}
  '';
};

