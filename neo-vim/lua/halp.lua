--*******************************************************************************
-- :Halp — my own cheat sheet, for the things I keep forgetting. Whichever module
-- owns a binding registers its own section with M.add{}; this module only
-- renders them, in registration order. Open with :Halp or <leader>? ; dismiss
-- with q or <Esc>.
--*******************************************************************************
local M = {}

local KEY_WIDTH = 15

local sections = {}

-- section = { title = "Buffers", entries = { { "<key or :Cmd>", "what it does" } } }
-- An entry with an empty key is a continuation line, aligned under the previous one.
function M.add(section)
    table.insert(sections, section)
end

local function render()
    local lines = { " nvim cheat sheet                    :Halp / <leader>? " }
    for _, section in ipairs(sections) do
        table.insert(lines, "")
        table.insert(lines, " " .. section.title)
        for _, entry in ipairs(section.entries) do
            table.insert(lines, "   " .. string.format("%-" .. KEY_WIDTH .. "s%s", entry[1], entry[2]))
        end
    end
    return lines
end

function M.open()
    local lines = render()

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.bo[buf].bufhidden = "wipe"

    local width = 0
    for _, l in ipairs(lines) do
        width = math.max(width, #l)
    end
    width = math.min(width + 2, vim.o.columns - 4)
    -- Scrolls once the sheet outgrows the screen, rather than overflowing it.
    local height = math.min(#lines, vim.o.lines - 6)

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2 - 1),
        col = math.floor((vim.o.columns - width) / 2),
        style = "minimal",
        border = "rounded",
        title = " Halp ",
    })
    vim.wo[win].wrap = false

    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, nowait = true })
    vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = buf, nowait = true })
end

vim.api.nvim_create_user_command("Halp", M.open, { desc = "Show the nvim cheat sheet" })
vim.keymap.set("n", "<leader>?", M.open, { silent = true, desc = "Show the nvim cheat sheet" })

M.add({
    title = "Buffers",
    entries = {
        { ":f <name>", "name the current buffer without saving it" },
        { ":0file",    "drop the name again (unmodified buffers only)" },
        { ":Wipeout",  "close every hidden, unmodified buffer" },
    },
})

M.add({
    title = "Panes",
    entries = {
        { "<leader>z",   "zoom / restore the focused pane  (:Zoom)" },
        { "<C-h/j/k/l>", "move between panes  (also <D-h/j/k/l>)" },
    },
})

M.add({
    title = "Files",
    entries = {
        { "<leader>n", "toggle the file browser (Neo-tree)" },
        { "?",         "inside Neo-tree: full Neo-tree help" },
    },
})

return M
