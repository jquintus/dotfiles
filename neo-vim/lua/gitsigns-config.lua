-- Gitsigns configuration
local ok, gitsigns = pcall(require, 'gitsigns')
if not ok then return end

gitsigns.setup({
    signs = {
        add          = { text = '│' },
        change       = { text = '│' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
    },
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local opts = { buffer = bufnr }

        -- Navigation
        vim.keymap.set('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
        end, { buffer = bufnr, expr = true, desc = 'Next hunk' })

        vim.keymap.set('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
        end, { buffer = bufnr, expr = true, desc = 'Prev hunk' })

        -- Actions
        vim.keymap.set('n', '<leader>hs', gs.stage_hunk, opts)
        vim.keymap.set('n', '<leader>hr', gs.reset_hunk, opts)
        vim.keymap.set('n', '<leader>hp', gs.preview_hunk, opts)
        vim.keymap.set('n', '<leader>hb', function() gs.blame_line({ full = true }) end, opts)
    end,
})
