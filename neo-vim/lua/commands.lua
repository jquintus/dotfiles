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
