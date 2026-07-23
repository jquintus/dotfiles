local function open_sql_workspace()
    -- Avoid re-running if already set up
    if vim.g.sql_workspace_open then
        return
    end
    vim.g.sql_workspace_open = true

    -- Start with a clean layout
    vim.cmd("only")

    -- Pick the initial orientation based on how wide the window is *right now*.
    -- Wide (external monitor): side-by-side columns, editor | terminal.
    -- Narrow (laptop / half-screen): stacked, editor on top / terminal on bottom
    --   so wide psql result rows get the full width.
    -- You can reflow live at any time without restarting (see :Halp):
    --   <C-w>H makes columns, <C-w>J stacks them.
    local wide = vim.o.columns >= 200

    if wide then
        vim.cmd("vsplit")   -- editor | terminal
        vim.cmd("wincmd l") -- move to right pane
    else
        vim.cmd("split")    -- editor / terminal (stacked)
        vim.cmd("wincmd j") -- move to bottom pane
    end

    -- Open terminal
    vim.cmd("terminal zsh")

    -- Mark this buffer as the SQL target
    vim.b.sql = true

    -- Save the terminal window ID so we can return to it
    local terminal_win = vim.api.nvim_get_current_win()

    -- Go back to editor pane
    vim.cmd("wincmd " .. (wide and "h" or "k"))

    -- Optional: open Neo-tree
    vim.cmd("Neotree reveal left")

    -- Return to terminal window and enter insert mode
    vim.api.nvim_set_current_win(terminal_win)
    vim.cmd("startinsert")

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

    -- Switch DB connection: jump to the terminal and fire the `dbs` fzf picker
    -- (defined in _zshrc-aliases). Pick a connection and psql relaunches with its
    -- color-coded / banner prompt so you always know where you are.
    -- Note: run this from the shell prompt, not from inside an active psql session
    -- (\q first if you're already connected).
    vim.keymap.set("n", "<leader>C", function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.b[buf].sql and vim.bo[buf].buftype == "terminal" then
                vim.api.nvim_set_current_win(win)
                vim.fn.chansend(vim.bo[buf].channel, "dbs\n")
                vim.cmd("startinsert")
                return
            end
        end
        vim.notify("No SQL terminal found", vim.log.levels.ERROR)
    end, { desc = "Switch DB connection (dbs picker)" })
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
