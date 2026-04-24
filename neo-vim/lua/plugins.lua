--*******************************************************************************
-- Packer - Plugin manager
-- This will automatically install packer.nvim if it's not already installed
--
--*******************************************************************************
-- To install a new plugin
--*******************************************************************************
-- 1. Add the plugin to the plugins.lua file
-- 2. Run :PackerSync
--*******************************************************************************
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

-- Auto-install packer if not installed
if fn.empty(fn.glob(install_path)) > 0 then
    print("Installing packer.nvim...")
    fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd [[packadd packer.nvim]]
end

-- Add packer to runtime path
vim.opt.rtp:prepend(install_path)

-- Now you can safely require packer and define plugins
require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'

    -- Completion
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'

    -- LSP
    use 'neovim/nvim-lspconfig'
    use 'williamboman/mason.nvim'
    use 'williamboman/mason-lspconfig.nvim'

    -- Treesitter (better syntax highlighting)
    -- Run :TSUpdate manually after install
    use 'nvim-treesitter/nvim-treesitter'

    -- Telescope (fuzzy finder)
    use {
        'nvim-telescope/telescope.nvim',
        requires = { 'nvim-lua/plenary.nvim' }
    }

    -- Git
    use 'lewis6991/gitsigns.nvim'

    -- Slime - send code to tmux/terminal
    use 'jpalardy/vim-slime'

    -- Noice is a notification system for Neovim
    use 'MunifTanjim/nui.nvim'
    use 'folke/noice.nvim'

    -- Neo-tree (file explorer)
    use 'nvim-tree/nvim-web-devicons'
    use {
        'nvim-neo-tree/neo-tree.nvim',
        branch = 'v3.x',
        requires = {
            'nvim-lua/plenary.nvim',
            'nvim-tree/nvim-web-devicons',
            'MunifTanjim/nui.nvim',
        }
    }

    -- Commentary - gcc to comment/uncomment
    use 'tpope/vim-commentary'

    if packer_bootstrap then
        require('packer').sync()
    end
end)
