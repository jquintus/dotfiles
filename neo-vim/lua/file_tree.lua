--*******************************************************************************
-- Configure neo-tree (only after packer has loaded plugins)
--*******************************************************************************
-- Named file_tree.lua, not neo-tree.lua: that name collided with the plugin's own
-- module, so require('neo-tree') returned the plugin and this setup never ran.
-- Wrap in pcall to avoid errors if plugin isn't installed yet
local status_ok, neotree = pcall(require, "neo-tree")
if status_ok then
    neotree.setup({
        filesystem = {
            filtered_items = {
                visible = true,        -- show still-filtered items (gitignored), dimmed
                hide_dotfiles = false, -- show dotfiles normally
                hide_hidden = false,
            },
        },
    })
end
