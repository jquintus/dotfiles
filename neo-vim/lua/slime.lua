--*******************************************************************************
-- Vim Slime Configuration for Neovim
-- Send code from vim to tmux panes (useful for SQL queries, REPLs, etc.)
--*******************************************************************************

-- Use tmux as slime target
vim.g.slime_target = "tmux"

-- Hardcode target pane to :.0 (current window, pane 0)
-- Change if your psql/target pane is different
-- Examples:
--   "%0" - pane with ID 0
--   "psql-work" - pane with name "psql-work"
--   ":.0" - current window, pane 0 (most common)
vim.g.slime_default_config = {
    socket_name = "default",
    target_pane = ":.0"
}

-- Avoid prompt asking for slime target every time
vim.g.slime_dont_ask_default = 1

-- Set buffer-local slime config for each buffer
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function()
        vim.b.slime_config = vim.g.slime_default_config
    end,
})

--*******************************************************************************
-- Functions for SQL workflow
--*******************************************************************************

-- Function to save and send file to psql using \i command
function SaveAndSendToPsql()
    vim.cmd('write')
    local filepath = vim.fn.expand('%:p')
    vim.cmd('SlimeSend1 \\i ' .. filepath)
end

-- Function to save and send file to localdb
-- This runs against localdb but you can easily edit the command line after
-- to switch to a different database or pipe to pbcopy
function SaveAndSendToLocalDb()
    vim.cmd('write')
    local filepath = vim.fn.expand('%:p')
    vim.cmd('SlimeSend1 localdb -q -f ' .. filepath)
end

--*******************************************************************************
-- Keymaps
--*******************************************************************************

-- Map <leader>r to save and send current file to psql
vim.keymap.set('n', '<leader>r', ':lua SaveAndSendToPsql()<CR>', { silent = true, desc = "Save and send to psql" })

-- Map <leader>R to save and send to localdb
vim.keymap.set('n', '<leader>R', ':lua SaveAndSendToLocalDb()<CR>', { silent = true, desc = "Save and send to localdb" })

-- Send visual selection with <leader>s (uses vim-slime's default visual mode sending)
-- Default vim-slime binding is <C-c><C-c> in visual mode, but this is more convenient
vim.keymap.set('x', '<leader>s', '<Plug>SlimeRegionSend', { desc = "Send visual selection to tmux" })

--*******************************************************************************
-- Auto-send on save (commented out for safety)
--*******************************************************************************
-- Automatically send current file to psql pane on save
-- Commented out because it can be dangerous - you might save for many reasons
-- and don't want to accidentally run a query.
--
-- vim.api.nvim_create_autocmd("BufWritePost", {
--     pattern = "*.sql",
--     callback = function()
--         vim.cmd('SlimeSend1 \\i ' .. vim.fn.expand('%:p'))
--     end,
-- })
