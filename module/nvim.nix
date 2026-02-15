{
  config,
  pkgs,
  inputs,
  ...
}:
let
  # Read local files
  initLua = builtins.readFile ../files/nvim/init.lua;
  keymapsLua = builtins.readFile ../files/nvim/keymaps.lua;
  basharLua = builtins.readFile ../files/nvim/colors/bashar.lua;

in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.LEA =
    { pkgs, ... }:
    {
      home.stateVersion = "25.11";
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        withNodeJs = true;
        withPython3 = true;

        extraPackages = with pkgs; [
          git
          lazygit
          ripgrep
          fd
          fzf

          # --- THE FIX STARTS HERE ---
          luarocks # Required for plugins using rocks.nvim or lazy rocks
          tree-sitter # The CLI tool for managing parsers
          gcc # Ensure a C compiler is present for building parsers
          gnumake # Essential for building almost any native lua rock
          python3 # Often required by provider-based plugins
          # ---------------------------

          cargo
          unzip
          lua-language-server
          stylua
          shfmt
        ];
      };

      # Write configuration files
      xdg.configFile = {
        "nvim/init.lua".text = initLua;
        "nvim/lua/config/keymaps.lua".text = keymapsLua;
        "nvim/colors/bashar.lua".text = basharLua;
      };
    };
}
