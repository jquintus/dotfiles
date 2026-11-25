--*******************************************************************************
-- eyeliner.nvim: when you press f/F/t/T, the letter that reaches each word in
-- one jump lights up (primary color; secondary means press it twice).
--*******************************************************************************
local halp = require('halp')

local ok, eyeliner = pcall(require, 'eyeliner')
if ok then
    eyeliner.setup({
        highlight_on_key = true, -- only light up after pressing f/F/t/T
        dim = true,              -- dim the rest of the line so the targets stand out
    })
end

halp.add({
    title = 'Jump on the line (eyeliner.nvim)',
    entries = {
        { 'f / t', 'press it and the letter that reaches each word lights up; type it' },
        { '',      'dimmer highlight: that letter needs two presses (f<c> then ;)' },
        { 'F / T', 'same, backward' },
    },
})
