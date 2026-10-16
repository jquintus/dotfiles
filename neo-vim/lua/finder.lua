--*******************************************************************************
-- Finder: fzf-lua, the VS Code cmd-p / cmd-shift-f pair.
--
-- <C-p> fuzzy-opens a file in the repo, <leader>fg greps every file live.
-- Same fzf binary and keys as the shell (ctrl-j/k to move, enter to open,
-- ctrl-v / ctrl-s for a split, ctrl-q to send the hits to the quickfix list).
-- pcall'd so a fresh machine starts before :PackerSync has run.
--*******************************************************************************
local halp = require('halp')
local map = vim.keymap.set

local ok, fzf = pcall(require, 'fzf-lua')
if ok then
    fzf.setup({
        'default',
        winopts = { height = 0.85, width = 0.85, preview = { layout = 'vertical', vertical = 'down:50%' } },
        files = { git_icons = false }, -- faster on big repos
        -- ctrl-q = select everything and accept; multiple accepted entries land in the
        -- quickfix list. fzf-lua's own default for this is alt-q, which macOS terminals
        -- eat unless option-as-alt is on.
        keymap = { fzf = { ['ctrl-q'] = 'select-all+accept' } },
    })

    map('n', '<C-p>',      fzf.files,           { silent = true, desc = 'Find file (cmd-p)' })
    map('n', '<leader>ff', fzf.files,           { silent = true, desc = 'Find file' })
    map('n', '<leader>fg', fzf.live_grep,       { silent = true, desc = 'Grep all files (cmd-shift-f)' })
    map('n', '<leader>fw', fzf.grep_cword,      { silent = true, desc = 'Grep word under cursor' })
    map('v', '<leader>fg', fzf.grep_visual,     { silent = true, desc = 'Grep the selection' })
    map('n', '<leader>fb', fzf.buffers,         { silent = true, desc = 'Switch buffer' })
    map('n', '<leader>fo', fzf.oldfiles,        { silent = true, desc = 'Recent files' })
    map('n', '<leader>fr', fzf.resume,          { silent = true, desc = 'Reopen the last picker' })
end

halp.add({
    title = 'Find',
    entries = {
        { '<C-p>',      'open a file by fuzzy name  (also <leader>ff)' },
        { '<leader>fg', 'grep every file as you type; visual: grep the selection' },
        { '<leader>fw', 'grep the word under the cursor' },
        { '<leader>fb', 'switch buffer' },
        { '<leader>fo', 'recent files' },
        { '<leader>fr', 'reopen the last picker where you left it' },
        { '',           'inside: ctrl-v / ctrl-s open in a split, ctrl-q send all to quickfix' },
    },
})

halp.add({
    title = 'Quickfix (the list ctrl-q, :grep and :make fill)',
    entries = {
        { ':cnext', 'next hit  (:cprev previous, :cfirst / :clast)' },
        { ':copen', 'show the list, Enter on a row jumps there  (:cclose hides)' },
        { ':cdo <cmd>',     'run a command on every hit, e.g. :cdo s/a/b/g | update' },
    },
})
