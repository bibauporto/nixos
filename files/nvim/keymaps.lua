-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set

-- Note on Options:
-- lvim.format_on_save = true  -> In LazyVim, this is enabled by default. 
-- You can toggle it via vim.g.autoformat in lua/config/options.lua if needed.

-------------------------------------------------------------------------------
-- 1. CORE MOVEMENT (Destructured logic)
-------------------------------------------------------------------------------
local movement_maps = {
  ["q"] = "h",     -- Left
  ["n"] = "gj",    -- Down
  ["e"] = "gk",    -- Up
  ["i"] = "l",     -- Right
  ["Q"] = "0",
  ["I"] = "$",
  ["o"] = "e",
  ["O"] = "E",
  ["N"] = ")",
  ["E"] = "(",
  ["l"] = "i",     -- Insert
  ["L"] = "I",
  ["h"] = "n",     -- Search next
  ["H"] = "N",
  ["j"] = "o",     -- Open line below
  ["J"] = "O",
  ["d"] = '"_d',   -- Delete to black hole
}

-- Apply movement mappings to Normal and Visual modes
for lhs, rhs in pairs(movement_maps) do
  map({ "n", "v" }, lhs, rhs, { desc = "Remap movement " .. lhs })
end

-------------------------------------------------------------------------------
-- 2. NORMAL MODE SPECIFICS
-------------------------------------------------------------------------------
map("n", "K", "q", { desc = "Record macro" })
map("n", "k", "@", { desc = "Play macro" })
map("n", "U", "<C-r>", { desc = "Redo" })

-------------------------------------------------------------------------------
-- 3. LEADER MAPPINGS
-------------------------------------------------------------------------------
-- LazyVim handles WhichKey labels via the `desc` property in the options table.

local leader_maps = {
  { lhs = "<leader>f", rhs = "/", desc = "Search" },
  { lhs = "<leader>q", rhs = "<cmd>wincmd h<cr>", desc = "Focus Left" },
  { lhs = "<leader>i", rhs = "<cmd>wincmd l<cr>", desc = "Focus Right" },
  { lhs = "<leader>s", rhs = "<cmd>vsplit<cr>", desc = "Split Right" },
  { lhs = "<leader>S", rhs = "<cmd>split<cr>", desc = "Split Down" },
  { lhs = "<leader>e", rhs = "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
  { lhs = "<leader>n", rhs = "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
  { lhs = "<leader>o", rhs = "<C-r>", desc = "Redo" },
  { lhs = "<leader>a", rhs = "<cmd>Telescope lsp_document_symbols<cr>", desc = "Symbols" },
  -- Using `gcc` with remap allows this to work with whatever comment plugin LazyVim is using (Mini or others)
  { lhs = "<leader>d", rhs = "gcc", desc = "Comment Line", remap = true }, 
  { lhs = "<leader><leader>", rhs = "<cmd>Telescope find_files<cr>", desc = "Find Files" },
}

-- Destructuring leader mappings for cleaner iteration
for _, mapping in ipairs(leader_maps) do
  local opts = { desc = mapping.desc }
  if mapping.remap then opts.remap = true end
  map("n", mapping.lhs, mapping.rhs, opts)
end
