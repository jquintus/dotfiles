--*******************************************************************************
-- Git: diffview.nvim (the VS Code "changes" view) + gitsigns.nvim (hunk markers)
--
-- <leader>hd opens the changed-file panel on the left and a side-by-side diff
-- on the right. The right-hand buffer is the real file: edit it, :w, done.
-- Everything is pcall'd so a fresh machine starts before :PackerSync has run.
--*******************************************************************************
local halp = require('halp')
local map = vim.keymap.set

-- diffview ---------------------------------------------------------------------
local has_diffview, diffview = pcall(require, 'diffview')
if has_diffview then
    diffview.setup({
        enhanced_diff_hl = true,
        view = { merge_tool = { layout = 'diff3_mixed' } },
    })

    local function toggle()
        if require('diffview.lib').get_current_view() then
            vim.cmd('DiffviewClose')
        else
            vim.cmd('DiffviewOpen')
        end
    end

    map('n', '<leader>hd', toggle, { silent = true, desc = 'Diffview: toggle changed files vs HEAD' })
    map('n', '<leader>hH', '<cmd>DiffviewFileHistory %<CR>', { silent = true, desc = 'Diffview: history of this file' })
end

-- gitsigns ---------------------------------------------------------------------
local has_gitsigns, gitsigns = pcall(require, 'gitsigns')
if has_gitsigns then
    gitsigns.setup({
        on_attach = function(bufnr)
            local function bmap(mode, lhs, rhs, desc)
                map(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
            end

            -- ]c / [c: native diff-mode jumps when in a diff, hunk jumps otherwise.
            bmap('n', ']c', function()
                if vim.wo.diff then vim.cmd.normal({ ']c', bang = true }) else gitsigns.nav_hunk('next') end
            end, 'Next hunk')
            bmap('n', '[c', function()
                if vim.wo.diff then vim.cmd.normal({ '[c', bang = true }) else gitsigns.nav_hunk('prev') end
            end, 'Previous hunk')

            bmap('n', '<leader>hs', gitsigns.stage_hunk, 'Stage hunk (again to unstage)')
            bmap('v', '<leader>hs', function()
                gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
            end, 'Stage selected lines')
            bmap('n', '<leader>hr', gitsigns.reset_hunk, 'Reset hunk')
            bmap('n', '<leader>hp', gitsigns.preview_hunk, 'Preview hunk')
            bmap('n', '<leader>hb', function() gitsigns.blame_line({ full = true }) end, 'Blame line')
        end,
    })
end

halp.add({
    title = 'Git',
    entries = {
        { '<leader>hd', 'toggle the changed-files diff view (edit the right pane, :w)' },
        { '<Tab>',      'in the file panel: next file   (- stage, S stage all, g? help)' },
        { ']c  [c',     'next / previous hunk' },
        { '<leader>hs', 'stage this hunk (again to unstage; works on a selection)' },
        { '<leader>hr', 'throw this hunk away' },
        { '<leader>hp', 'preview this hunk' },
        { '<leader>hH', 'history of the current file' },
        { ':DiffviewOpen', 'main...HEAD   review a whole branch' },
    },
})
