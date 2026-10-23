--*******************************************************************************
-- Custom commands
--*******************************************************************************

-- Delete all buffers that aren't displayed in tabs/windows and aren't modified
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

-- Close file buffers while leaving the file browser and an empty editor open.
local function close_all_buffers(opts)
    local buffers = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buflisted and vim.bo[buf].buftype == '' then
            if not opts.bang and vim.bo[buf].modified then
                vim.api.nvim_err_writeln('Unsaved changes; use :ba! to discard them')
                return
            end
            table.insert(buffers, buf)
        end
    end

    local windows = {}
    local tree_open = false
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == 'neo-tree' then
            tree_open = true
        elseif vim.tbl_contains(buffers, buf) then
            table.insert(windows, win)
        end
    end

    if #windows > 0 then
        local empty = vim.api.nvim_create_buf(true, false)
        for _, win in ipairs(windows) do
            vim.api.nvim_win_set_buf(win, empty)
        end
    elseif tree_open then
        vim.cmd('rightbelow vnew')
    end

    for _, buf in ipairs(buffers) do
        vim.api.nvim_buf_delete(buf, { force = opts.bang })
    end
end

vim.api.nvim_create_user_command('Ba', close_all_buffers, { bang = true, desc = 'Close all file buffers' })
vim.cmd([[cnoreabbrev <expr> ba (getcmdtype() ==# ':' && getcmdline() ==# 'ba') ? 'Ba' : 'ba']])

-- Running psql in vim
vim.api.nvim_create_user_command('LocalDB', 'leftabove vertical 30split | terminal localdb', {})
vim.api.nvim_create_user_command('Foo', 'leftabove vertical 30split | terminal localdb', {})
vim.api.nvim_create_user_command('Bar', 'topleft vertical 30vsplit | wincmd H | terminal localdb', {})

-- Prevail over shift-happy fingers.
vim.cmd("cabbr Wq wq")
vim.cmd("cabbr qw wq")
vim.cmd("cabbr Qw wq")
vim.cmd("cabbr Wqa wqa")
vim.cmd("cabbr W w")
vim.cmd("cabbr WQ wq")
