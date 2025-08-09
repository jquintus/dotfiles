--*******************************************************************************
-- Configure variables
--*******************************************************************************
local PersonalVimRc = "~/.vimrc"
local PersonalVimDir = "~/OneDrive/bin/config/vimfiles/"

-- Key mappings for personal vimrc
vim.keymap.set('n', '<F3>', function()
    vim.cmd("source " .. PersonalVimRc)
end, { noremap = true })

vim.keymap.set('n', '<S-F3>', function()
    vim.cmd("e " .. PersonalVimRc)
end, { noremap = true })

vim.keymap.set('n', '<leader>sv', function()
    vim.cmd("source " .. PersonalVimRc)
end, { noremap = true })

vim.keymap.set('n', '<leader>ev', function()
    vim.cmd("e " .. PersonalVimRc)
end, { noremap = true })

--*******************************************************************************
-- Mac Specific Stuff
-- <D-j> : this maps the "command key + j"
--*******************************************************************************
-- To set colors up in ITerm
-- https://tomlankhorst.nl/iterm-tmux-vim-true-color/
vim.opt.termguicolors = true
vim.opt.t_8f = "\27[38;2;%lu;%lu;%lum"
vim.opt.t_8b = "\27[48;2;%lu;%lu;%lum"

-- Note: pathogen#infect() is not needed in Neovim, use a package manager instead
-- filetype plugin indent on
vim.cmd("filetype plugin indent on")
-- syntax on
vim.cmd("syntax on")

-- Mac-specific key mappings
vim.keymap.set('n', '<D-cr>', ':set fu!<CR>', { noremap = true })
vim.keymap.set('n', '<D-j>', '<C-w>j', { noremap = true })
vim.keymap.set('n', '<D-h>', '<C-w>h', { noremap = true })
vim.keymap.set('n', '<D-k>', '<C-w>k', { noremap = true })
vim.keymap.set('n', '<D-l>', '<C-w>l', { noremap = true })

--*******************************************************************************
-- Create directories
--*******************************************************************************
local function ensure_dir_exists(path)
    if vim.fn.isdirectory(path) == 0 then
        vim.fn.mkdir(path, "p")
    end
end

ensure_dir_exists(vim.fn.expand("$HOME/.vim_backup"))
ensure_dir_exists(vim.fn.expand("$HOME/.vim_undo"))
ensure_dir_exists(vim.fn.expand("$HOME/OneDrive/bin/config/vimfiles"))

--*******************************************************************************
-- Sets
--*******************************************************************************

-- Window navigation
vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true })
vim.keymap.set('n', '<C-h>', '<C-w>h', { noremap = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { noremap = true })

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
vim.opt.breakindentopt = "shift:4"      -- Additional indent when doing a soft wrap 

-- Indentation
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true

-- Backup settings
vim.opt.backup = true                   -- keep backup copies
vim.opt.backupdir = "~/.vim_backup"     -- save all backups in one directory
vim.opt.directory = "~/.vim_backup"     -- put swaps files here too
vim.opt.undodir = "~/.vim_undo"         -- put swaps files here too
vim.opt.backupext = ".bak"              -- don't use that weird ~ extension
vim.opt.ruler = true                    -- show column/row count (on by default)

vim.opt.showcmd = true                  -- show key sequence in status line

-- GUI options
vim.opt.guioptions = vim.opt.guioptions + "bh"  -- b=> bottom scrollbar; h=> quick scrollbar
vim.opt.guioptions = vim.opt.guioptions - "L"   -- Removing L fixes the problem where gVim changes size and moves when a tab is opened or closed
vim.opt.diffopt = vim.opt.diffopt + "vertical"  -- Diff with vertical split
vim.opt.guifont = "Menlo-Regular:h16"

vim.opt.encoding = "utf-8"
vim.cmd("color desert")

vim.opt.autoread = true                 -- Automatically reload a file when it has been changed on disk

vim.g.mapleader = " "

--*******************************************************************************
-- Keyboard mappings
--*******************************************************************************
-- open/reread config file
vim.keymap.set('n', '<C-F3>', ':source ~/_vimrc<CR>', { noremap = true })
vim.keymap.set('n', '<CS-F3>', ':e ~/_vimrc<CR>', { noremap = true })

vim.keymap.set('n', '<F5>', ':e!<CR>zz', { noremap = true })
vim.keymap.set('n', '<S-F5>', ':e!<CR>Gzz', { noremap = true })

-- Remove highlights when you hit enter
vim.keymap.set('n', '<CR>', ':noh<CR>j', { noremap = true })

-- Tab Completion in edit mode
vim.keymap.set('n', '<Tab>', ':bn<CR>', { noremap = true })
vim.keymap.set('n', '<S-Tab>', ':bp<CR>', { noremap = true })

-- Cycle between tabs
vim.keymap.set('n', '<C-Tab>', ':tabNext<CR>', { noremap = true })
vim.keymap.set('n', '<F10>', ':tabnew<CR>', { noremap = true })
vim.keymap.set('n', '<C-n>', ':tabnew<CR>', { noremap = true })
vim.keymap.set('n', '<S-F10>', ':tabclose<CR>', { noremap = true })
vim.keymap.set('n', '<C-F10>', ':tabclose!<CR>', { noremap = true })

-- Simple Edits: next + do-again, down + do-again
vim.keymap.set('n', '<F6>', 'n.', { noremap = true })
vim.keymap.set('n', '<S-F6>', 'nn.', { noremap = true })
vim.keymap.set('n', '<F7>', 'j.', { noremap = true })

-- Sort uniques
vim.keymap.set('n', '<M-Space>', '<Esc>:sort u<CR>:echo "Sorted"<CR>', { noremap = true })
vim.keymap.set('n', '<leader>r', ':g/^/m0<CR>:echo "Reversed all lines in file"<CR>', { noremap = true })

vim.keymap.set('n', '<F4>', '<C-h>:diffthis<CR><C-l>:diffthis<CR>', { noremap = true })

-- Copy the entire file to the clipboard and return to the current line
vim.keymap.set('n', '<C-Space>', '<Esc>mzggVG"*y`z:delmarks c<CR>:echo "File copied to clipboard"<CR>', { noremap = true })

-- J/K work on word wrapped lines now
vim.keymap.set('n', 'j', 'gj', { noremap = true })
vim.keymap.set('n', 'k', 'gk', { noremap = true })

-- Filtering
vim.keymap.set('n', '<leader>v', ':v::d<CR>', { noremap = true })
vim.keymap.set('n', '<leader>g', ':g::d<CR>', { noremap = true })

-- Copy all lines that match the current search to the default buffer
vim.keymap.set('n', '<leader>y', 'qyqmy:g::y Y<CR>:let @+ =@y<CR>`y', { noremap = true })

-- Prevail over shift-happy fingers.
vim.cmd("cabbr Wq wq")
vim.cmd("cabbr qw wq")
vim.cmd("cabbr Qw wq")
vim.cmd("cabbr Wqa wqa")
vim.cmd("cabbr W w")
vim.cmd("cabbr WQ wq")

--*******************************************************************************
-- Configure <TAB> to tab-completion when at the end of a word
--*******************************************************************************
-- Note: These functions need to be implemented differently in Lua
-- For now, using the basic tab completion
vim.keymap.set('i', '<Tab>', '<C-n>', { noremap = true })
vim.keymap.set('i', '<S-Tab>', '<C-p>', { noremap = true })

--*******************************************************************************
-- Toggle Word Wrap with <F2>
--*******************************************************************************
vim.keymap.set('n', '<F2>', ':setlocal wrap!<CR>', { noremap = true })
vim.keymap.set('n', '<S-F2>', ':setlocal wrap!<CR>:setlocal lbr!<CR>', { noremap = true })
vim.keymap.set('n', '<C-F2>', 'gq}', { noremap = true })

--*******************************************************************************
-- Syntax Highlighting
--*******************************************************************************
vim.keymap.set('n', '<F11>', function()
    -- Toggle syntax highlighting
    if not vim.b.syntax then
        vim.b.syntax = 0
    end
    
    if vim.b.syntax == 0 then
        vim.b.syntax = 1
        vim.cmd("setlocal syntax=cs")
        print("Setting syntax to C#")
    elseif vim.b.syntax == 1 then
        vim.b.syntax = 2
        vim.cmd("setlocal syntax=xml")
        print("Setting syntax to Xml")
    elseif vim.b.syntax == 2 then
        vim.b.syntax = 3
        vim.cmd("setlocal syntax=sqlanywhere")
        print("Setting syntax to Sql")
    elseif vim.b.syntax == 3 then
        vim.b.syntax = 4
        vim.cmd("setlocal syntax=javascript")
        print("Setting syntax to JavaScript")
    elseif vim.b.syntax == 4 then
        vim.b.syntax = 5
        vim.cmd("setlocal syntax=json")
        print("Setting syntax to Json")
    elseif vim.b.syntax == 5 then
        vim.b.syntax = 6
        vim.cmd("setlocal syntax=java")
        print("Setting syntax to Java")
    elseif vim.b.syntax == 6 then
        vim.b.syntax = 7
        vim.cmd("setlocal syntax=python")
        print("Setting syntax to Python")
    else
        vim.b.syntax = 0
        vim.cmd("setlocal syntax=off")
        print("Turning off syntax highlighting")
    end
end, { noremap = true })

vim.b.syntax = 0

--*******************************************************************************
-- Search for selected text with * and #
--*******************************************************************************
local function v_set_search()
    local temp = vim.fn.getreg('"')
    vim.cmd('norm! gvy')
    local search_term = '\\V' .. vim.fn.substitute(vim.fn.escape(vim.fn.getreg('"'), '\\'), '\\n', '\\\\n', 'g')
    vim.fn.setreg('/', search_term)
    vim.fn.setreg('"', temp)
end

vim.keymap.set('v', '*', function()
    v_set_search()
    vim.cmd('//')
end, { noremap = true })

vim.keymap.set('v', '#', function()
    v_set_search()
    vim.cmd('??')
end, { noremap = true })

--******************************************************************************
-- Alt-period replay the last ex command
--*******************************************************************************
vim.keymap.set('n', '<M-.>', ':<Up><CR>', { noremap = true })

--*******************************************************************************
-- Hidden - One particularly useful setting is hidden. Its name isn't too descriptive,
-- though. It hides buffers instead of closing them. This means that you can
-- have unwritten changes to a file and open a new file using :e, without being
-- forced to write or undo your changes first. Also, undo buffers and marks are
-- preserved while the buffer is open. This is an absolute must-have.
--*******************************************************************************
vim.opt.hidden = true

--*******************************************************************************
-- Insert the line number at the beginning/end of a line
--*******************************************************************************
vim.keymap.set('n', '<leader>ln', ':%s/^/\\=line("."). " "/<CR>', { noremap = true })

--*******************************************************************************
-- Stolen from mswin.vim
--*******************************************************************************
-- CTRL-X and SHIFT-Del are Cut
vim.keymap.set('v', '<C-X>', '"+x', { noremap = true })
vim.keymap.set('v', '<S-Del>', '"+x', { noremap = true })

-- CTRL-C and CTRL-Insert are Copy
vim.keymap.set('v', '<C-C>', '"+y', { noremap = true })
vim.keymap.set('v', '<C-Insert>', '"+y', { noremap = true })

-- CTRL-V and SHIFT-Insert are Paste
vim.keymap.set('n', '<S-Insert>', '"+gP', { noremap = true })
vim.keymap.set('v', '<S-Insert>', '"+gP', { noremap = true })

vim.cmd("cmap <S-Insert> <C-R>+")

-- CTRL-A is copy all
vim.keymap.set('n', '<M-A>', 'mcggVG"+y\'c:delmarks c<CR>:echo "File copied to clipboard"<CR>', { noremap = true })

--*******************************************************************************
-- Delete all buffers that aren't displayed in tabs/windows and aren't modified
--*******************************************************************************
local function wipeout()
    local tpbl = {}
    for i = 1, vim.fn.tabpagenr('$') do
        local tab_buffers = vim.fn.tabpagebuflist(i)
        for _, buf in ipairs(tab_buffers) do
            table.insert(tpbl, buf)
        end
    end
    
    local wiped = 0
    for buf = 1, vim.fn.bufnr('$') do
        if vim.fn.bufexists(buf) == 1 and vim.fn.index(tpbl, buf) == -1 and vim.fn.getbufvar(buf, "&mod") == 0 then
            vim.cmd('bwipeout! ' .. buf)
            wiped = wiped + 1
        end
    end
    print(wiped .. ' buffers deleted')
end

vim.api.nvim_create_user_command('Wipeout', wipeout, {})

--*******************************************************************************
-- Special file type handling
--*******************************************************************************
-- JSON syntax highlighting using javascript
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = "*.json",
    command = "set filetype=json"
})

vim.keymap.set('n', '<F12>', ':1,$ ! jq "." -<CR>:set syntax=json<CR>', { noremap = true })

vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = "*.vssettings",
    command = "set filetype=xml"
})

vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
    pattern = "*.xaml",
    command = "setf xml"
})

vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = "*.fsproj",
    command = "set filetype=xml"
})

--*******************************************************************************
-- Auto highlight current word when idle
--*******************************************************************************
local function auto_highlight_toggle()
    vim.fn.setreg('/', '')
    if vim.fn.exists('#auto_highlight') == 1 then
        vim.cmd('au! auto_highlight')
        vim.cmd('augroup! auto_highlight')
        vim.opt.updatetime = 4000
        print('Highlight current word: off')
        return 0
    else
        vim.cmd('augroup auto_highlight')
        vim.cmd('au!')
        vim.cmd('au CursorHold * let @/ = \'\\V\\<\\' .. vim.fn.escape(vim.fn.expand('<cword>'), '\\') .. '\\>\'')
        vim.cmd('augroup end')
        vim.opt.updatetime = 500
        print('Highlight current word: ON')
        return 1
    end
end

vim.keymap.set('n', '<leader>/', function()
    if auto_highlight_toggle() then
        vim.opt.hls = true
    end
end, { noremap = true })

--*******************************************************************************
-- Notes
--*******************************************************************************
-- edit my notes file
vim.keymap.set('n', '<leader>b', ':next $HOME/OneDrive/bin/config/vimfiles/notes.bat<CR>', { noremap = true })
vim.keymap.set('n', '<leader>c', ':next $HOME/OneDrive/bin/config/vimfiles/notes.cs<CR>', { noremap = true })
vim.keymap.set('n', '<leader>j', ':next $HOME/OneDrive/bin/config/vimfiles/notes.json<CR>', { noremap = true })
vim.keymap.set('n', '<leader>m', ':next $HOME/OneDrive/bin/config/vimfiles/notes.md<CR>', { noremap = true })
vim.keymap.set('n', '<leader>s', ':next $HOME/OneDrive/bin/config/vimfiles/notes.sql<CR>', { noremap = true })
vim.keymap.set('n', '<leader>t', ':next $HOME/OneDrive/bin/config/vimfiles/notes.txt<CR>', { noremap = true })
vim.keymap.set('n', '<leader>e', ':next $HOME/OneDrive/bin/config/vimfiles/notes_encrypted.txt<CR>', { noremap = true })
vim.keymap.set('n', '<leader>x', ':next $HOME/OneDrive/bin/config/vimfiles/notes.xml<CR>', { noremap = true })
vim.keymap.set('n', '<leader>d', ':next $HOME/OneDrive/bin/config/vimfiles/destiny_notes.txt<CR>', { noremap = true })

vim.keymap.set('n', 't?', function()
    print('<leader>b => notes.bat')
    print('<leader>c => notes.cs')
    print('<leader>j => notes.json')
    print('<leader>m => notes.md')
    print('<leader>s => notes.sql')
    print('<leader>t => notes.txt')
    print('<leader>x => notes.xml')
end, { noremap = true })

--*******************************************************************************
-- Markdown
--*******************************************************************************
vim.keymap.set('n', '<Leader>4', 'ciw[<C-r>"](<Esc>"*pli)<Esc>', { noremap = true })
vim.keymap.set('v', '<Leader>4', 'c[<C-r>"](<Esc>"*pli)<Esc>', { noremap = true })

vim.keymap.set('n', ',', 'ciw[<C-r>"](<Esc>"*pli)<Esc>', { noremap = true })
vim.keymap.set('v', ',', 'c[<C-r>"](<Esc>"*pli)<Esc>', { noremap = true })

vim.opt.rtp = vim.opt.rtp + "/usr/local/opt/fzf"
vim.g.fzf_history_dir = '~/.vimfzf-history'

--*******************************************************************************
-- Running psql in vim
--*******************************************************************************
vim.api.nvim_create_user_command('LocalDB', 'leftabove vertical 30split | terminal localdb', {})
vim.api.nvim_create_user_command('Foo', 'leftabove vertical 30split | terminal localdb', {})
vim.api.nvim_create_user_command('Bar', 'topleft vertical 30vsplit | wincmd H | terminal localdb', {})
