--*******************************************************************************
-- Keyboard mappings
--*******************************************************************************

local variables = require('variables')

-- Key mappings for personal vimrc
vim.keymap.set('n', '<F3>', function()

    vim.cmd("source " .. "/Users/jq/dotfiles/neo-vim/int.lua")
    vim.api.nvim_echo({{"Reloading int.lua", "None"}}, false, {})

end, { noremap = true })

vim.keymap.set('n', '<S-F3>', function()
    local command = "e " .. variables.PersonalVimRc
    print(command)
    vim.cmd(command)
    -- vim.cmd("e " .. "/Users/jq/dotfiles/neo-vim/int.lua")
end, { noremap = true })

vim.keymap.set('n', '<leader>sv', function()
    vim.cmd("source " .. variables.PersonalVimRc)
end, { noremap = true })

vim.keymap.set('n', '<leader>ev', function()
    vim.cmd("e " .. variables.PersonalVimRc)
end, { noremap = true })

-- Window navigation
vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true })
vim.keymap.set('n', '<C-h>', '<C-w>h', { noremap = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { noremap = true })

vim.keymap.set('n', '<F5>', ':e!<CR>zz', { noremap = true })
vim.keymap.set('n', '<S-F5>', ':e!<CR>Gzz', { noremap = true })

-- Remove highlights when you hit enter
vim.keymap.set('n', '<CR>', ':noh<CR>j', { noremap = true })

-- Use tab to cycle through buffers
vim.keymap.set('n', '<Tab>', ':bn<CR>', { noremap = true })
vim.keymap.set('n', '<S-Tab>', ':bp<CR>', { noremap = true })

-- Tab Completion in edit mode
vim.keymap.set('i', '<Tab>', '<C-n>', { noremap = true })
vim.keymap.set('i', '<S-Tab>', '<C-p>', { noremap = true })

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
-- Alt-period replay the last ex command
vim.keymap.set('n', '<M-.>', ':<Up><CR>', { noremap = true })

-- Sort uniques
vim.keymap.set('n', '<M-Space>', '<Esc>:sort u<CR>:echo "Sorted"<CR>', { noremap = true })
vim.keymap.set('n', '<leader>r', ':g/^/m0<CR>:echo "Reversed all lines in file"<CR>', { noremap = true })

vim.keymap.set('n', '<F4>', function()
    vim.cmd('wincmd h')
    vim.cmd('diffthis')
    vim.cmd('wincmd l')
    vim.cmd('diffthis')
end, { noremap = true })

-- Copy the entire file to the clipboard and return to the current line
vim.keymap.set('n', '<C-Space>', function()
    -- Remember where we are at the start
    vim.cmd("normal! mz")

    -- Select and copy the entire file
    vim.cmd("normal! ggVG")
    vim.cmd('normal! "*y')

    -- Return to saved cursor position and delete the mark
    vim.cmd("normal! `z")
    vim.cmd("delmarks c")

    print("File copied to clipboard")
end, { noremap = true })

-- Filtering
vim.keymap.set('n', '<leader>v', ':v::d<CR>', { noremap = true })
vim.keymap.set('n', '<leader>g', ':g::d<CR>', { noremap = true })

-- Copy all lines that match the current search to the default buffer
vim.keymap.set('n', '<leader>y', function()
    -- Clear the y register
    vim.fn.setreg('y', '')
    
    -- Create a mark so we can come back here later
    vim.cmd("normal! my")
    
    -- Copy all lines that match the current search to the y buffer
    vim.cmd("g//y Y")
    
    -- Copy the content of the y buffer to the clipboard
    vim.fn.setreg('+', vim.fn.getreg('y'))
    
    -- Move the cursor back to the starting position
    vim.cmd("normal! `y")
end, { noremap = true })


-------------------------------------------------------------------------------
-- Word Wrapping
-------------------------------------------------------------------------------
-- J/K work on word wrapped lines now
vim.keymap.set('n', 'j', 'gj', { noremap = true })
vim.keymap.set('n', 'k', 'gk', { noremap = true })

-- F2: Toggle word wrapping on/off for current buffer
vim.keymap.set('n', '<F2>', ':setlocal wrap!<CR>', { noremap = true })
-- Shift+F2: Toggle word wrapping AND line break mode (only break at word boundaries)
vim.keymap.set('n', '<S-F2>', ':setlocal wrap!<CR>:setlocal lbr!<CR>', { noremap = true })
-- Ctrl+F2: Format/reflow the current paragraph 
vim.keymap.set('n', '<C-F2>', 'gq}', { noremap = true })

-------------------------------------------------------------------------------
-- Syntax Highlighting
-------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------
-- Search
-------------------------------------------------------------------------------
-- Search for selected text with * and #
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

-------------------------------------------------------------------------------
-- Clipboard
-- Some of these may be windows specific
-------------------------------------------------------------------------------
-- Stolen from mswin.vim
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
vim.keymap.set('n', '<M-a>', function()
    vim.api.nvim_echo({{"Copying entire file to clipboard", "None"}}, false, {})

    -- Save current position in mark 'c'
    vim.cmd('normal! mc')
    vim.cmd('normal! ggVG"+y')
    
    -- Return to the saved position and delete the mark
    vim.cmd("normal! `c")
    vim.cmd('delmarks c')

    vim.api.nvim_echo({{"File copied to clipboard", "None"}}, false, {})
end, { noremap = true })

-------------------------------------------------------------------------------
-- Line Numbers
-------------------------------------------------------------------------------
-- Insert the line number at the beginning/end of a line
vim.keymap.set('n', '<leader>ln', ':%s/^/\\=line("."). " "/<CR>', { noremap = true })


-- Notes
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
    vim.api.nvim_echo({
        {'<leader>b => notes.bat'},
        {'\n<leader>c => notes.cs'},
        {'\n<leader>j => notes.json'},
        {'\n<leader>m => notes.md'},
        {'\n<leader>s => notes.sql'},
        {'\n<leader>t => notes.txt'},
        {'\n<leader>x => notes.xml'}
    }, false, {})
end, { noremap = true })

-- Markdown
vim.keymap.set('n', '<Leader>4', 'ciw[<C-r>"](<Esc>"*pli)<Esc>', { noremap = true })
vim.keymap.set('v', '<Leader>4', 'c[<C-r>"](<Esc>"*pli)<Esc>', { noremap = true })

vim.keymap.set('n', ',', 'ciw[<C-r>"](<Esc>"*pli)<Esc>', { noremap = true })
vim.keymap.set('v', ',', 'c[<C-r>"](<Esc>"*pli)<Esc>', { noremap = true })

-------------------------------------------------------------------------------
-- Auto highlight current word when idle
-------------------------------------------------------------------------------
local function auto_highlight_toggle()
    vim.fn.setreg('/', '')
    if vim.fn.exists('#auto_highlight') == 1 then
        vim.cmd('au! auto_highlight')
        vim.cmd('augroup! auto_highlight')
        vim.opt.updatetime = 4000
        vim.api.nvim_echo({{'Highlight current word: off', 'None'}}, false, {})
        return 0
    else
        vim.api.nvim_create_augroup('auto_highlight', { clear = true })
        vim.api.nvim_create_autocmd('CursorHold', {
            group = 'auto_highlight',
            callback = function()
                local word = vim.fn.expand('<cword>')
                if word ~= '' then
                    vim.fn.setreg('/', '\\V\\<' .. vim.fn.escape(word, '\\') .. '\\>')
                end
            end
        })
        vim.opt.updatetime = 500
        vim.api.nvim_echo({{'Highlight current word: ON', 'None'}}, false, {})
        return 1
    end
end

vim.keymap.set('n', '<leader>/', function()
    if auto_highlight_toggle() then
        vim.opt.hls = true
    end
end, { noremap = true })
