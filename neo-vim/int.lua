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
require('commands') -- to be tested

if vim.fn.has('mac') == 1 then
    -- Load macOS-specific settings only on macOS
    require('mac-specific')
end

if vim.fn.has('win') == 1 then
    -- Load Windows-specific settings only on Windows
    require('win-specific')
end
