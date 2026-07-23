-- Find the psql/SQL terminal buffer (marked with b:sql on creation).
local function find_sql_term()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.b[buf].sql and vim.bo[buf].buftype == "terminal" then
            return buf
        end
    end
end

-- Pick the buffer to use as the editor pane: the current file if we're on one,
-- otherwise the first listed, named file buffer, otherwise whatever's current.
local function pick_editor_buf()
    local cur = vim.api.nvim_get_current_buf()
    local function is_file(b)
        return vim.bo[b].buftype == "" and vim.bo[b].buflisted
            and vim.api.nvim_buf_get_name(b) ~= ""
    end
    if is_file(cur) then
        return cur
    end
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if is_file(b) then
            return b
        end
    end
    return cur
end

-- Deterministically (re)build the SQL workspace into a known layout.
-- Always produces the same result: Neo-tree left (fixed width) + editor + the
-- SQL terminal, split either as columns (vertical=true) or stacked
-- (vertical=false), with the editor/terminal sized evenly every time. Which pane
-- is where and how big never depends on cursor position or current window sizes.
local function layout_sql(vertical)
    local term = find_sql_term()
    if not term then
        vim.notify("No SQL terminal found", vim.log.levels.ERROR)
        return
    end
    local editor = pick_editor_buf()

    -- Tear everything down, then lay it out from scratch.
    pcall(vim.cmd, "Neotree close")
    vim.cmd("only")
    vim.api.nvim_set_current_buf(editor)

    -- File browser first, so the editor/terminal split evenly in what's left.
    vim.cmd("Neotree show left")
    vim.cmd("wincmd l") -- move out of the tree into the editor area

    if vertical then
        vim.cmd("vsplit")
        vim.cmd("wincmd l") -- terminal on the right
    else
        vim.cmd("split")
        vim.cmd("wincmd j") -- terminal on the bottom
    end
    vim.api.nvim_set_current_buf(term)

    -- Pin the tree to a fixed width so the editor/terminal balance is repeatable.
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local b = vim.api.nvim_win_get_buf(win)
        if vim.bo[b].filetype == "neo-tree" then
            vim.api.nvim_win_set_width(win, 32)
            vim.wo[win].winfixwidth = true
        end
    end
    vim.cmd("wincmd =") -- editor vs terminal 50/50 (tree is fixed, unaffected)

    -- Land in the editor, ready to type.
    vim.cmd("wincmd " .. (vertical and "h" or "k"))
end

local function open_sql_workspace()
    -- Avoid re-running if already set up
    if vim.g.sql_workspace_open then
        return
    end
    vim.g.sql_workspace_open = true

    -- Create the psql terminal, then arrange deterministically.
    vim.cmd("only")
    vim.cmd("vsplit")
    vim.cmd("wincmd l")
    vim.cmd("terminal zsh")
    vim.b.sql = true

    -- Pick the initial orientation from how wide the window is *at launch*:
    -- wide (external monitor) -> columns; narrow (laptop/half-screen) -> stacked
    -- so wide psql result rows get the full width. Switch anytime, deterministically:
    --   <leader>|  -> columns     <leader>-  -> stacked   (see :Halp)
    local wide = vim.o.columns >= 200
    layout_sql(wide)

    -- Drop into the terminal in insert mode, as before.
    local term_win
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.b[vim.api.nvim_win_get_buf(win)].sql then
            term_win = win
        end
    end
    if term_win then
        vim.api.nvim_set_current_win(term_win)
        vim.cmd("startinsert")
    end

    -- Deterministic relayout keymaps. Same panes, same places, same sizes, always.
    vim.keymap.set("n", "<leader>|", function() layout_sql(true) end,
        { silent = true, desc = "SQL layout: columns (editor | terminal)" })
    vim.keymap.set("n", "<leader>-", function() layout_sql(false) end,
        { silent = true, desc = "SQL layout: stacked (editor / terminal)" })

    -- Set global <leader>r mapping for SQL workspace mode
    -- This overrides any previous <leader>r mapping (like the one from slime.lua)
    vim.keymap.set("n", "<leader>r", function()
        vim.cmd("w")
        local file = vim.fn.expand("%:p")

        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.b[buf].sql and vim.bo[buf].buftype == "terminal" then
                local chan = vim.bo[buf].channel
                vim.fn.chansend(chan, "\\i " .. file .. "\n")
                return
            end
        end

        vim.notify("No SQL terminal found", vim.log.levels.ERROR)
    end, { desc = "Save and send to SQL terminal (nvim workspace)" })

    -- Set visual mode mapping to send selected text to SQL terminal
    vim.keymap.set("v", "<leader>r", function()
        -- Get the selected text
        local start_pos = vim.fn.getpos("'<")
        local end_pos = vim.fn.getpos("'>")
        local lines = vim.fn.getline(start_pos[2], end_pos[2])

        -- Handle single line selection
        if #lines == 1 then
            lines[1] = string.sub(lines[1], start_pos[3], end_pos[3])
        else
            -- Handle multi-line selection
            lines[1] = string.sub(lines[1], start_pos[3])
            lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
        end

        local text = table.concat(lines, "\n")

        -- Find SQL terminal and send text
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.b[buf].sql and vim.bo[buf].buftype == "terminal" then
                local chan = vim.bo[buf].channel
                vim.fn.chansend(chan, text .. "\n")
                return
            end
        end

        vim.notify("No SQL terminal found", vim.log.levels.ERROR)
    end, { desc = "Send visual selection to SQL terminal" })
end

-- Open SQL workspace when vim is opened like this
-- SVIM=1 nvim
-- This is aliased to `sql`
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.env.SVIM == "1" then
            open_sql_workspace()
        end
    end,
})
