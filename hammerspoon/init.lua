-- Hammerspoon main config.
--
-- Feature modules live alongside this file (each symlinked from the dotfiles
-- repo into ~/.hammerspoon/) and are loaded here via require. To add a feature,
-- drop a new module next to this file and require it below.

-- Load IPC so the `hs` command-line tool can drive Hammerspoon,
-- e.g. `hs -c "hs.reload()"`. (Requires one manual reload to take effect.)
require("hs.ipc")

require("meet").bind()      -- Google Meet global controls (see meet.lua)
require("mutebar").start()  -- Menu-bar Meet mic indicator (see mutebar.lua)

hs.alert.show("Hammerspoon config loaded")
