--*******************************************************************************
-- Settings
--*******************************************************************************

-- Create directories
local function ensure_dir_exists(path)
    if vim.fn.isdirectory(path) == 0 then
        vim.fn.mkdir(path, "p")
    end
end

ensure_dir_exists(vim.fn.expand("$HOME/.vim_backup"))
ensure_dir_exists(vim.fn.expand("$HOME/.vim_undo"))
ensure_dir_exists(vim.fn.expand("$HOME/OneDrive/bin/config/vimfiles"))

-- Mac Specific Stuff
-- To set colors up in ITerm
-- https://tomlankhorst.nl/iterm-tmux-vim-true-color/
vim.opt.termguicolors = true

-- Filetype and syntax
vim.cmd("filetype plugin indent on")
vim.cmd("syntax on")

-- Search settings
vim.opt.hlsearch = true                 -- Turn on search highlighting
vim.opt.smartcase = true                -- Ignore case in searches until you start typing caps
vim.opt.ignorecase = true               -- Ignore case in searches
vim.opt.incsearch = true                -- Highlight as you type search strings

vim.opt.compatible = false

-- Wrap settings
vim.opt.wrap = false                    -- By default, don't do word wrap
vim.opt.linebreak = true                -- Don't just wrap at the last character, only wrap at words
vim.opt.breakindent = true              -- Match the main line's indent when doing a soft wrap

-- Indentation
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true

-- Backup settings
vim.opt.backup = true                   -- keep backup copies
vim.opt.backupdir = "~/.vim_backup"     -- save all backups in one directory
vim.opt.directory = "~/.vim_backup"     -- put swaps files here too
vim.opt.undodir = "~/.vim_undo"         -- put swaps files here too
vim.opt.backupext = ".bak"              -- don't use that weird ~ extension - not supported in Neovim
vim.opt.ruler = true                    -- show column/row count (on by default)

vim.opt.showcmd = true                  -- show key sequence in status line

-- GUI options - simplified for Neovim
vim.opt.encoding = "utf-8"
vim.cmd("color desert")

vim.opt.autoread = true                 -- Automatically reload a file when it has been changed on disk

vim.g.mapleader = " "

-- Hidden - One particularly useful setting is hidden. Its name isn't too descriptive,
-- though. It hides buffers instead of closing them. This means that you can
-- have unwritten changes to a file and open a new file using :e, without being
-- forced to write or undo your changes first. Also, undo buffers and marks are
-- preserved while the buffer is open. This is an absolute must-have.
vim.opt.hidden = true
