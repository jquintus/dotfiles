-- Hammerspoon main config.
--
-- Feature modules live alongside this file (each symlinked from the dotfiles
-- repo into ~/.hammerspoon/) and are loaded here via require. To add a feature,
-- drop a new module next to this file and require it below.

require("meet").bind() -- Google Meet global controls (see meet.lua)

hs.alert.show("Hammerspoon config loaded")
