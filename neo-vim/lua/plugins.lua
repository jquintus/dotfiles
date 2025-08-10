--*******************************************************************************
-- Packer - Plugin manager
-- This will automatically install packer.nvim if it's not already installed
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

    -- Add your other plugins here
    use 'tpope/vim-dadbod'
    use 'kristijanhusak/vim-dadbod-ui'
    use 'kristijanhusak/vim-dadbod-completion'

    -- Automatically set up your configuration after cloning packer.nvim
    if packer_bootstrap then
        require('packer').sync()
    end
end)
