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

-- Copy/paste
vim.keymap.set('v', '<D-x>', '"+x', { noremap = true })
vim.keymap.set('v', '<D-c>', '"+y', { noremap = true })
vim.keymap.set('n', '<D-c>', '"+p', { noremap = true })
vim.keymap.set('i', '<D-c>', '<C-r>+', { noremap = true })

vim.api.nvim_set_keymap('i', '<C-v>', '<C-r>+', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<D-v>', '<C-r>+', { noremap = true, silent = true })

-------------------------------------------------------------------------------
-- Neovide specific settings
-- https://neovide.dev/configuration.html
-------------------------------------------------------------------------------
-- Let neovim recognize the command key as the logo key
if vim.g.neovide then
    vim.g.neovide_input_use_logo = true
    vim.g.neovide_input_macos_option_key_is_meta = "both"
end
