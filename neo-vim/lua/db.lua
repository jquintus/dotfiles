-- Install dadbod and dadbod-ui with your plugin manager (e.g. packer.nvim)

-- Set DB aliases for vim-dadbod
vim.g.dbs = {
    { name = 'localdb', url = 'postgres://htu@localhost:5432/htdb' },
    { name = 'replica', url = 'postgres://readonly@production-htdb-replica/htdb' },
}

-- Map <leader>r to run the current query or file
vim.api.nvim_set_keymap(
    "n",
    "<leader>r",
    "<cmd>DBExec<CR>",
    { noremap = true, silent = true }
)

-- Optional: open the dadbod UI in a split with <leader>u
vim.api.nvim_set_keymap(
    "n",
    "<leader>u",
    "<cmd>DBUIToggle<CR>",
    { noremap = true, silent = true }
)
