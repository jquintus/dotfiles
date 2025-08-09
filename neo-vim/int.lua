-- Neovim configuration file (init.lua)
-- Converted from _vimrc

-- External vimrc path
local external_vimrc = "/Users/jq/OneDrive/bin/config/vimfiles/vimrc.mac.txt"

-- Source the external vimrc file
vim.cmd("source " .. external_vimrc)

-- Set colorscheme (after external vimrc to avoid being overridden)
vim.cmd("colorscheme murphy")

-- Key mappings (exact conversion from _vimrc)
vim.keymap.set('n', ':', function()
    vim.cmd("source " .. external_vimrc)
end, { noremap = true })

vim.keymap.set('n', '<S-F3>', function()
    vim.cmd("e " .. external_vimrc)
end, { noremap = true })
