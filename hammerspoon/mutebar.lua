-- Menu-bar Google Meet mic indicator.
--
-- Polls meet.micState() and shows your current state in the menu bar, so you
-- always know if you are live even when the Meet window is hidden. Click the
-- item to toggle mute. It disappears when you are not in a call.
-- Loaded from init.lua via require("mutebar").start().

local meet = require("meet")

local M = {}

local bar = nil
local poller = nil
local INTERVAL = 2 -- seconds between polls

local function render()
  local state = meet.micState()
  if state == nil then
    -- Not in a call (or controls not ready): hide the item entirely.
    if bar then bar:removeFromMenuBar() end
    return
  end
  bar:returnToMenuBar()
  if state == "muted" then
    bar:setTitle("🔇 Muted")
  else
    bar:setTitle("🔴 Live")
  end
end

function M.start()
  if bar then return end -- idempotent across reloads
  bar = hs.menubar.new()
  bar:setClickCallback(function()
    meet.toggleMic()
    hs.timer.doAfter(0.3, render) -- let Meet flip state, then refresh the title
  end)
  render()
  poller = hs.timer.doEvery(INTERVAL, render)
end

return M
