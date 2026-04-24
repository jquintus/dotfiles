-- LSP Configuration
-- After setup, run :MasonInstall typescript-language-server

local ok_mason, mason = pcall(require, 'mason')
if not ok_mason then return end

local ok_mason_lsp, mason_lspconfig = pcall(require, 'mason-lspconfig')
if not ok_mason_lsp then return end

local ok_lspconfig, lspconfig = pcall(require, 'lspconfig')
if not ok_lspconfig then return end

local ok_cmp_lsp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')

-- Mason setup (must come before lspconfig)
mason.setup()
mason_lspconfig.setup({
    ensure_installed = { 'ts_ls' },
})

-- LSP keymaps (set when LSP attaches to a buffer)
local on_attach = function(client, bufnr)
    local opts = { buffer = bufnr, noremap = true, silent = true }

    -- Navigation
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)

    -- Actions
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format({ async = true }) end, opts)

    -- Diagnostics
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
end

-- Capabilities for nvim-cmp
local capabilities = ok_cmp_lsp and cmp_nvim_lsp.default_capabilities() or {}

-- TypeScript
lspconfig.ts_ls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
})

-- Add more language servers here as needed:
-- lspconfig.lua_ls.setup({ on_attach = on_attach, capabilities = capabilities })
-- lspconfig.pyright.setup({ on_attach = on_attach, capabilities = capabilities })
