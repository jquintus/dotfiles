--*******************************************************************************
-- Auto commands
--*******************************************************************************

-- Special file type handling
-- JSON syntax highlighting.
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "*.json",
    command = "set filetype=json"
})

-- JSONL uses the same tokens, but JSON's missing-comma rule also matches the
-- newline between two independent records. Limit that rule to spaces and tabs
-- within a record while keeping the jsonl filetype.
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "*.jsonl",
    callback = function()
        vim.bo.syntax = "json"
        vim.cmd("syntax clear jsonMissingCommaError")
        vim.cmd([=[syntax match jsonMissingCommaError /\("\|\]\|\d\)\zs[[:blank:]]\+\ze"/]=])
        vim.cmd([=[syntax match jsonMissingCommaError /\(\]\|}\)[[:blank:]]\+\ze"/]=])
        vim.cmd([=[syntax match jsonMissingCommaError /}[[:blank:]]\+\ze{/]=])
        vim.cmd([=[syntax match jsonMissingCommaError /\(true\|false\)[[:blank:]]\+\ze"/]=])
    end,
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
