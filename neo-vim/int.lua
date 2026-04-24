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
require('netrw')
require('neo-tree-config')
require('plugins')
require('slime')
require('lsp')
require('completion_engine')
require('treesitter')
require('telescope-config')
require('gitsigns-config')
require('sql')

if vim.fn.has('mac') == 1 then
    -- Load macOS-specific settings only on macOS
    require('mac-specific')
end

if vim.fn.has('win') == 1 then
    -- Load Windows-specific settings only on Windows
    require('win-specific')
end

local ok_noice, noice = pcall(require, "noice")
if ok_noice then
    noice.setup({
        presets = {
            command_palette = true,
            long_message_to_split = true,
        },
    })
end
