-- Neovim configuration file (init.lua)
-- Converted from _vimrc

-- Add the current directory to the Lua path so we can find our modules
local current_dir = '/Users/jq/dotfiles/neo-vim/lua'
package.path = package.path .. ';' .. current_dir .. '/?.lua;' .. current_dir .. '/?/init.lua'


vim.keymap.set('c', '<D-v>', '<C-r>+', { noremap = true, silent = true })

-- Load just the test module
require('test')
require('neovide')
require('variables')
require('settings')
require('keymaps')
require('autocmds')     -- to be tested
require('commands')     -- to be tested
require('mac-specific') -- to be tested
