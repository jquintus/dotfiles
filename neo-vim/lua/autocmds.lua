--*******************************************************************************
-- Auto commands
--*******************************************************************************

-- Auto-save when focus is lost (helpful when working with Claude Code)
vim.api.nvim_create_autocmd("FocusLost", {
    pattern = "*",
    callback = function()
        if vim.bo.modified and vim.bo.buftype == "" and vim.fn.expand("%") ~= "" then
            vim.cmd("silent! write")
        end
    end,
})

-- Special file type handling
-- JSON syntax highlighting using javascript
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "*.json",
    command = "set filetype=json"
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "*.vssettings",
    command = "set filetype=xml"
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.xaml",
    command = "setf xml"
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "*.fsproj",
    command = "set filetype=xml"
})
