-- Menu-bar controls dropdown.
--
-- A persistent menu-bar item (🎛️) whose dropdown exposes every action that is
-- otherwise only reachable via a global hotkey, so you can drive them by mouse
-- when you are just on the laptop without a macropad. Loaded from init.lua via
-- require("controls").start().
--
-- The menu is built fresh on each click (setMenu is given a function), so item
-- labels can reflect live state: the Meet controls show their current mode and
-- are disabled when there is no active call.

local meet    = require("meet")
local meeting = require("meeting")
local layout  = require("layout")

local M = {}

local bar = nil

-- Build the dropdown fresh on each open so labels track current state.
local function buildMenu()
  local mic = meet.micState() -- "muted" | "live" | nil (no call)
  local inCall = mic ~= nil

  return {
    { title = "Google Meet", disabled = true },
    {
      title = mic == "live" and "  🔇 Mute mic" or "  🎤 Unmute mic",
      disabled = not inCall,
      fn = meet.toggleMic,
    },
    { title = "  📹 Toggle camera", disabled = not inCall, fn = meet.toggleCamera },
    { title = "  ✋ Raise / lower hand", disabled = not inCall, fn = meet.toggleHand },
    { title = "  🔗 Copy Meet link", disabled = not inCall, fn = meet.copyLink },
    { title = "-" },
    { title = "📅 Join next meeting", fn = meeting.joinNext },
    { title = "🪟 Arrange layout", fn = layout.apply },
    { title = "-" },
    { title = "↻ Reload Hammerspoon", fn = function() hs.reload() end },
  }
end

function M.start()
  if bar then return end -- idempotent across reloads
  bar = hs.menubar.new()
  bar:setTitle("🎛️")
  bar:setTooltip("Hammerspoon controls")
  bar:setMenu(buildMenu) -- pass the function so it re-evaluates on each open
end

return M
