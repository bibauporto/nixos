{
  inputs,
  ...
}:

let
  # Standard LazyVim bootstrap configuration
  lazyConfig = ''
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
      vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
      })
    end
    vim.opt.rtp:prepend(lazypath)

    require("lazy").setup({
      spec = {
        -- add LazyVim and import its plugins
        { "LazyVim/LazyVim", import = "lazyvim.plugins" },
        { import = "lazyvim.plugins.extras.editor.telescope" },
        { import = "lazyvim.plugins.extras.lang.typescript" },
        { import = "lazyvim.plugins.extras.lang.json" },
        -- import/override with your plugins if you have a plugins directory
        -- { import = "plugins" },
      },
      defaults = {
        -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
        -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
        lazy = false,
        -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
        -- have outdated releases, which may break your Neovim install.
        version = false, -- always use the latest git commit
        -- version = "*", -- try installing the latest stable version for plugins that support semver
      },
      install = { colorscheme = { "tokyonight", "habamax" } },
      checker = { enabled = true }, -- automatically check for plugin updates
      lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json", -- NixOS: write lockfile to writable dir
      performance = {
        rtp = {
          -- disable some rtp plugins
          disabled_plugins = {
            "gzip",
            -- "matchit",
            -- "matchparen",
            -- "netrwPlugin",
            "tarPlugin",
            "tohtml",
            "tutor",
            "zipPlugin",
          },
        },
      },
    })
  '';

  # Read local files
  initLua = builtins.readFile ../../files/nvim/init.lua;
  keymapsLua = builtins.readFile ../../files/nvim/keymaps.lua;
  basharLua = builtins.readFile ../../files/nvim/colors/bashar.lua;

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
      };

      # Write configuration files
      xdg.configFile = {
        "nvim/init.lua".text = initLua;
        "nvim/lua/config/lazy.lua".text = lazyConfig;
        "nvim/lua/config/keymaps.lua".text = keymapsLua;
        "nvim/colors/bashar.lua".text = basharLua;
      };
    };
}
