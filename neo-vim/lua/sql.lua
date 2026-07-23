-- Find the psql/SQL terminal buffer (marked with b:sql on creation).
local function find_sql_term()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.b[buf].sql and vim.bo[buf].buftype == "terminal" then
            return buf
        end
    end
end

-- A real, editable buffer: a normal file buffer, never neo-tree, netrw, the
-- terminal, or any other special/scratch listing.
local function is_editable(b)
    return vim.api.nvim_buf_is_valid(b)
        and vim.bo[b].buftype == ""
        and vim.bo[b].buflisted
        and vim.bo[b].filetype ~= "neo-tree"
        and vim.bo[b].filetype ~= "netrw"
end

-- Pick the buffer for the editor pane: the current file if we're on one, else a
-- named file buffer, else any empty normal buffer we can reuse. Returns nil when
-- nothing suitable exists, so the caller creates a fresh empty buffer instead of
-- falling back to netrw's directory listing.
local function pick_editor_buf()
    local cur = vim.api.nvim_get_current_buf()
    if is_editable(cur) and vim.api.nvim_buf_get_name(cur) ~= "" then
        return cur
    end
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if is_editable(b) and vim.api.nvim_buf_get_name(b) ~= "" then
            return b
        end
    end
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if is_editable(b) then
            return b
        end
    end
    return nil
end

-- Deterministically (re)build the SQL workspace into a known layout.
-- Always produces the same result: editor + SQL terminal (columns when
-- vertical=true, stacked when vertical=false) with Neo-tree on the far left.
-- Which pane is where never depends on cursor position or current sizes.
--
-- Neo-tree's open/close is ASYNCHRONOUS, so we build editor+terminal fully
-- (all synchronous) FIRST, then open Neo-tree as the very last step with no
-- window ops depending on it. Doing window splits right after a Neotree
-- close/show races the async and randomly drops the tree.
local function layout_sql(vertical)
    local term = find_sql_term()
    if not term then
        vim.notify("No SQL terminal found", vim.log.levels.ERROR)
        return
    end
    local editor = pick_editor_buf()

    -- Collapse to a single window showing a real editor buffer. `only` also
    -- closes any existing Neo-tree window.
    vim.cmd("only")
    if editor then
        vim.api.nvim_set_current_buf(editor)
    else
        -- No real file open yet: fresh empty buffer, NOT netrw's dir listing.
        vim.cmd("enew")
    end

    -- Editor + terminal, evenly split. Fully synchronous, no Neo-tree involved.
    if vertical then
        vim.cmd("vsplit")
        vim.cmd("wincmd l") -- terminal on the right
    else
        vim.cmd("split")
        vim.cmd("wincmd j") -- terminal on the bottom
    end
    vim.api.nvim_set_current_buf(term)
    vim.cmd("wincmd =")

    -- Back to the editor, then open the file browser LAST (async-safe).
    vim.cmd("wincmd " .. (vertical and "h" or "k"))
    vim.cmd("Neotree show left")
end

-- Deterministic relayout keymaps, defined at module level so they survive an
-- <F3> reload and work any time a SQL terminal exists (they no-op with a notice
-- otherwise). | and \ are the same physical key (shift / no-shift).
vim.keymap.set("n", "<leader>|", function() layout_sql(true) end,
    { silent = true, desc = "SQL layout: columns (editor | terminal)" })
vim.keymap.set("n", "<leader>\\", function() layout_sql(false) end,
    { silent = true, desc = "SQL layout: stacked (editor / terminal)" })

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
    --   <leader>|  -> columns     <leader>\  -> stacked   (see :Halp)
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
