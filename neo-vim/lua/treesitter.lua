-- Treesitter configuration
local ok, configs = pcall(require, 'nvim-treesitter.configs')
if not ok then return end

configs.setup({
    ensure_installed = {
        'typescript',
        'tsx',
        'javascript',
        'json',
        'lua',
        'python',
        'sql',
        'bash',
        'markdown',
        'yaml',
    },
    highlight = {
        enable = true,
    },
    indent = {
        enable = true,
    },
})
