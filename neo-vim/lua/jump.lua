--*******************************************************************************
-- flash.nvim: jump anywhere on screen by typing a few characters, then the label.
-- s       type 1-2 characters, then the colored label that appears at the target
-- f/t/F/T enhanced: every match is highlighted; press f again to step to the next
--*******************************************************************************
local halp = require('halp')

local ok, flash = pcall(require, 'flash')
if ok then
    flash.setup({})
    vim.keymap.set({ 'n', 'x', 'o' }, 's', flash.jump, { desc = 'Flash jump' })
end

halp.add({
    title = 'Jump (flash.nvim)',
    entries = {
        { 's',       'type 1-2 chars of the target, then its colored label' },
        { '',        'works after an operator too: ds<chars><label> deletes up to there' },
        { 'f / t',   'every match lights up; press f again (or ;) for the next one' },
        { 'F / T',   'same, backward' },
    },
})
