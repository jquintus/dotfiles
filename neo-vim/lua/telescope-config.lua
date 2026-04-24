-- Telescope configuration (fuzzy finder)
local ok, telescope = pcall(require, 'telescope')
if not ok then return end

local builtin = require('telescope.builtin')

telescope.setup({
    defaults = {
        file_ignore_patterns = { 'node_modules', '.git/', 'dist/' },
    },
})

-- Keymaps
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags' })
vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, { desc = 'Document symbols' })
vim.keymap.set('n', '<leader>fr', builtin.lsp_references, { desc = 'References' })

-- Quick access with Ctrl+p (common in many editors)
vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = 'Find files' })
