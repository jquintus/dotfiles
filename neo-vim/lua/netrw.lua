-- Netrw is a built in folder explorer for neovim
-- We don't need to install NERDTree as a file explorer

-- Keymaps for easier navigation
vim.keymap.set("n", "-", "<cmd>Explore<CR>", { desc = "Open netrw in current file's directory" })
vim.keymap.set("n", "<leader>n", "<cmd>Lexplore<CR>", { desc = "Toggle netrw in a vertical split" })

-- Netrw configuration (Vinegar-style)
vim.g.netrw_banner = 0                -- hide the banner at the top
vim.g.netrw_liststyle = 3             -- tree view by default
vim.g.netrw_browse_split = 0          -- open files in the same window
vim.g.netrw_winsize = 45              -- width of netrw window
vim.g.netrw_altv = 1                  -- open splits to the right
vim.g.netrw_keepdir = 0               -- keep the browsing directory synced with cwd
vim.g.netrw_localcopydircmd = 'cp -r' -- recursive copy
vim.g.netrw_preview = 1               -- preview in a vertical split


vim.g.netrw_list_hide = [[\(^\|\s\s\)\zs\.\S\+,\(^\|\s\s\)\zs\.DS_Store]]

-- Optional: start netrw in the directory of the current file when opening a directory
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
            vim.cmd("Explore")
        end
    end
})
