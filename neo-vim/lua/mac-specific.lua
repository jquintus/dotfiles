--*******************************************************************************
-- Mac Specific Stuff
-- <D-j> : this maps the "command key + j"
--*******************************************************************************

-- FZF integration
vim.opt.rtp = vim.opt.rtp + "/usr/local/opt/fzf"
vim.g.fzf_history_dir = '~/.vimfzf-history'

-- Additional Mac-specific settings and mappings can be added here

-- Mac-specific key mappings
vim.keymap.set('n', '<D-cr>', ':set fu!<CR>', { noremap = true })
vim.keymap.set('n', '<D-j>', '<C-w>j', { noremap = true })
vim.keymap.set('n', '<D-h>', '<C-w>h', { noremap = true })
vim.keymap.set('n', '<D-k>', '<C-w>k', { noremap = true })
vim.keymap.set('n', '<D-l>', '<C-w>l', { noremap = true })
