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

--*******************************************************************************
-- :Halp  — my own cheat sheet. Edit the lines below whenever you learn/change a
-- binding. Open with :Halp or <leader>?  ; dismiss with q or <Esc>.
--*******************************************************************************
local halp_lines = {
    " SQL workspace cheat sheet          :Halp / <leader>?  ",
    "",
    " Panes",
    "   <leader>z      zoom / restore focused pane (full screen)",
    "   <C-h/j/k/l>    move between panes   (also <D-h/j/k/l>)",
    "   <C-w>H         reflow to columns  (editor | terminal)",
    "   <C-w>J         reflow to stacked  (editor / terminal)",
    "",
    " Files",
    "   <leader>n      toggle file browser (Neo-tree)",
    "   ?              (inside Neo-tree) full Neo-tree help",
    "",
    " Run SQL",
    "   <leader>r      save file + run it in psql  (\\i file)",
    "   <leader>r      (visual) send selection to psql",
    "",
    " Connections",
    "   <leader>C      switch DB connection (dbs picker, at shell prompt)",
    "",
    " Clipboard",
    "   y / <leader>y  copy selection to system clipboard",
    "   Cmd+C          copy selection (no longer cuts)",
}

local function halp()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, halp_lines)
    vim.bo[buf].modifiable = false
    vim.bo[buf].bufhidden = "wipe"

    local width = 0
    for _, l in ipairs(halp_lines) do
        width = math.max(width, #l)
    end
    width = width + 2
    local height = #halp_lines

    vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2 - 1),
        col = math.floor((vim.o.columns - width) / 2),
        style = "minimal",
        border = "rounded",
        title = " Halp ",
    })

    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, nowait = true })
    vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = buf, nowait = true })
end

vim.api.nvim_create_user_command("Halp", halp, {})
vim.keymap.set("n", "<leader>?", halp, { silent = true, desc = "Show :Halp cheat sheet" })

-- Prevail over shift-happy fingers.
vim.cmd("cabbr Wq wq")
vim.cmd("cabbr qw wq")
vim.cmd("cabbr Qw wq")
vim.cmd("cabbr Wqa wqa")
vim.cmd("cabbr W w")
vim.cmd("cabbr WQ wq")
