-- Neovim configuration file (init.lua)
-- Converted from _vimrc

-- Add the current directory to the Lua path so we can find our modules
local current_dir = '/Users/jq/dotfiles/neo-vim/lua'
package.path = package.path .. ';' .. current_dir .. '/?.lua;' .. current_dir .. '/?/init.lua'

-- Load just the test module
require('test')
require('neovide')
require('variables')
require('settings')
require('keymaps')
require('autocmds')
require('commands')
require('netrw')    -- Replaces NERDTree
require('neo-tree') -- Neo-tree for file explorer
require('plugins')
require('slime')    -- Vim-slime for sending code to tmux
require('completion_engine')
require('sql')

if vim.fn.has('mac') == 1 then
    -- Load macOS-specific settings only on macOS
    require('mac-specific')
end

if vim.fn.has('win') == 1 then
    -- Load Windows-specific settings only on Windows
    require('win-specific')
end

require("noice").setup({
    -- You can customize settings here; for now, keep it simple
    presets = {
        command_palette = true,
        long_message_to_split = true,
    },
    -- optionally, disable some defaults if you want
    -- messages = { enabled = false },
    -- cmdline = { enabled = false },
})
