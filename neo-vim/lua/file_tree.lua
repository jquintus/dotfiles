--*******************************************************************************
-- Configure neo-tree (only after packer has loaded plugins)
--*******************************************************************************
-- Wrap in pcall to avoid errors if plugin isn't installed yet
local status_ok, neotree = pcall(require, "neo-tree")
if status_ok then
    neotree.setup({})
end

-- NOTE: this file's module name ("neo-tree") collides with the neo-tree.nvim
-- plugin, so at startup `require('neo-tree')` may return the plugin and skip this
-- file entirely. Do NOT put keymaps here expecting them to load -- they live in
-- keymaps.lua instead. (<leader>n toggles the tree; press ? inside it for help.)
