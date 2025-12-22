--*******************************************************************************
-- Mac Specific Stuff
-- <D-j> : this maps the "command key + j"
--*******************************************************************************

-- To set colors up in ITerm
-- https://tomlankhorst.nl/iterm-tmux-vim-true-color/
vim.opt.termguicolors = true

-- FZF integration
vim.opt.rtp = vim.opt.rtp + "/usr/local/opt/fzf"
vim.g.fzf_history_dir = '~/.vimfzf-history'

vim.keymap.set('n', '<D-cr>', ':set fu!<CR>', { noremap = true })

-- Mac Cmd-J, H, K, L are window navigation
vim.keymap.set('n', '<D-j>', '<C-w>j', { noremap = true })
vim.keymap.set('n', '<D-h>', '<C-w>h', { noremap = true })
vim.keymap.set('n', '<D-k>', '<C-w>k', { noremap = true })
vim.keymap.set('n', '<D-l>', '<C-w>l', { noremap = true })

-- Visual mode: <leader>y to copy to system clipboard
vim.keymap.set('v', '<leader>y', '"+y', { noremap = true, desc = "Copy to system clipboard" })

-- Normal mode: <leader>p to paste from system clipboard
vim.keymap.set('n', '<leader>p', '"+p', { noremap = true, desc = "Paste from system clipboard" })
vim.keymap.set('n', '<leader>P', '"+P', { noremap = true, desc = "Paste before cursor from system clipboard" })

-- Insert mode: Ctrl-V to paste from system clipboard (works in terminal)
vim.keymap.set('i', '<C-v>', '<C-r>+', { noremap = true, silent = true })

-- GUI-specific Cmd key mappings (for Neovide, not for terminal)
if vim.g.neovide then
    vim.keymap.set('v', '<D-x>', '"+x', { noremap = true })
    vim.keymap.set('v', '<D-c>', '"+y', { noremap = true })
    vim.keymap.set('n', '<D-v>', '"+p', { noremap = true })
    vim.keymap.set('v', '<D-v>', '"+p', { noremap = true })
    vim.keymap.set('i', '<D-v>', '<C-r>+', { noremap = true })
end

-------------------------------------------------------------------------------
-- Neovide specific settings
-- https://neovide.dev/configuration.html
-------------------------------------------------------------------------------
-- Let neovim recognize the command key as the logo key
if vim.g.neovide then
    vim.g.neovide_input_use_logo = true
    vim.g.neovide_input_macos_option_key_is_meta = "both"
end
