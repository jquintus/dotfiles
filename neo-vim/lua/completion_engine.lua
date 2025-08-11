-- Configuration for nvim-cmp - Autocompletion plugin
local cmp = require('cmp')

cmp.setup({
    snippet = {
        expand = function(args)
            -- For now, no snippet engine is configured
            -- You can add luasnip or vsnip later if you want
        end,
    },
    mapping = {
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Confirm completion with Enter
        ['<C-n>'] = cmp.mapping.select_next_item(),        -- Next completion item
        ['<C-p>'] = cmp.mapping.select_prev_item(),        -- Previous completion item
    },
    sources = {
        { name = 'dadbod-completion' },
        { name = 'buffer' },
        { name = 'path' },
    },
})
