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

    -- Fetch the PR revisions without checking out the branch or changing files.
    -- Diffview's right pane then contains the complete file from the PR head.
    vim.api.nvim_create_user_command('PrReview', function(opts)
        local root = vim.fn.systemlist({ 'git', 'rev-parse', '--show-toplevel' })[1]
        if vim.v.shell_error ~= 0 or not root then
            vim.notify('PrReview: open Neovim inside a Git repository', vim.log.levels.ERROR)
            return
        end

        local gh_args = { 'gh', 'pr', 'view' }
        if opts.args ~= '' then
            table.insert(gh_args, opts.args)
        end
        vim.list_extend(gh_args, { '--json', 'number,baseRefName,baseRefOid,headRefOid' })

        vim.system(gh_args, { cwd = root, text = true }, function(pr_result)
            vim.schedule(function()
                if pr_result.code ~= 0 then
                    vim.notify('PrReview: ' .. vim.trim(pr_result.stderr), vim.log.levels.ERROR)
                    return
                end

                local ok, pr = pcall(vim.json.decode, pr_result.stdout)
                if not ok or type(pr) ~= 'table' or not tonumber(pr.number)
                    or not tostring(pr.baseRefOid):match('^[0-9a-fA-F]+$')
                    or not tostring(pr.headRefOid):match('^[0-9a-fA-F]+$') then
                    vim.notify('PrReview: invalid PR data from gh', vim.log.levels.ERROR)
                    return
                end

                vim.notify('PrReview: fetching PR #' .. pr.number)
                vim.system({ 'git', 'fetch', '--no-tags', 'origin', pr.baseRefName,
                    'refs/pull/' .. pr.number .. '/head' }, { cwd = root, text = true }, function(fetch_result)
                    vim.schedule(function()
                        if fetch_result.code ~= 0 then
                            vim.notify('PrReview: ' .. vim.trim(fetch_result.stderr), vim.log.levels.ERROR)
                            return
                        end

                        for _, oid in ipairs({ pr.baseRefOid, pr.headRefOid }) do
                            vim.fn.system({ 'git', '-C', root, 'cat-file', '-e', oid .. '^{commit}' })
                            if vim.v.shell_error ~= 0 then
                                vim.notify('PrReview: PR changed during fetch; run it again', vim.log.levels.ERROR)
                                return
                            end
                        end

                        vim.cmd('DiffviewOpen ' .. pr.baseRefOid .. '...' .. pr.headRefOid)
                    end)
                end)
            end)
        end)
    end, { nargs = '?', desc = 'Review a GitHub PR with full file context' })
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
        { ':PrReview 123', 'review a PR with complete files (number or URL)' },
    },
})
