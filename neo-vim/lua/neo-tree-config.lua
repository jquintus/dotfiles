--*******************************************************************************
-- Configure neo-tree
--*******************************************************************************

vim.keymap.set('n', '<leader>n', function()
    vim.cmd('Neotree filesystem toggle left')
end, { noremap = true, silent = true, desc = "Toggle file tree" })

local status_ok, neotree = pcall(require, "neo-tree")
if not status_ok then return end

neotree.setup({
    window = {
        position = "left",
        width = 30,
    },
})
