--*******************************************************************************
-- Configure neo-tree (only after packer has loaded plugins)
--*******************************************************************************
-- Wrap in pcall to avoid errors if plugin isn't installed yet
local status_ok, neotree = pcall(require, "neo-tree")
if status_ok then
    neotree.setup({})
end
