--*******************************************************************************
-- Configure neo-tree (only after packer has loaded plugins)
--*******************************************************************************
-- Wrap in pcall to avoid errors if plugin isn't installed yet
local status_ok, neotree = pcall(require, "neo-tree")
if status_ok then
    neotree.setup({})
end

-- Toggle the file browser on demand (open if closed, close if open).
-- Once it's open, press `?` inside the tree for the full keybinding cheat sheet.
vim.keymap.set('n', '<leader>n', ':Neotree toggle left<CR>',
    { silent = true, desc = 'Toggle file browser (Neo-tree)' })
