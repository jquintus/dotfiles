-- Hammerspoon menu-bar controls.
--
-- Hammerspoon's own menu-bar icon has a fixed dropdown (Console / Reload /
-- Preferences / Quit) that the API can't append to. So instead we hide that
-- default icon and stand up our OWN hs.menubar item wearing the same status
-- icon, whose dropdown carries every hotkey action PLUS the standard items the
-- default menu had. The result reads as "the Hammerspoon icon, now with
-- buttons" and lets you drive everything by mouse when you're on the laptop
-- without a macropad. Loaded from init.lua via require("controls").start().
--
-- The menu is built fresh on each open (setMenu is given a function), so labels
-- track current state: the Meet controls show their mode and disable when there
-- is no active call.

local meet    = require("meet")
local meeting = require("meeting")
local layout  = require("layout")

local M = {}

local bar = nil

-- The same template PDF the built-in menu icon uses, so our replacement is
-- pixel-identical and adapts to light/dark menu bars.
local ICON = hs.image.imageFromPath(
  "/Applications/Hammerspoon.app/Contents/Resources/statusicon.pdf")

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
    -- The actions the default Hammerspoon menu used to give us.
    { title = "Console…", fn = function() hs.openConsole() end },
    { title = "Reload Config", fn = function() hs.reload() end },
    { title = "Preferences…", fn = function() hs.openPreferences() end },
    { title = "-" },
    { title = "Quit Hammerspoon", fn = function() os.exit() end },
  }
end

function M.start()
  if bar then return end -- idempotent across reloads
  hs.menuIcon(false)     -- retire the built-in icon; ours stands in for it
  bar = hs.menubar.new()
  if ICON then bar:setIcon(ICON, true) else bar:setTitle("🔨") end
  bar:setTooltip("Hammerspoon controls")
  bar:setMenu(buildMenu) -- pass the function so it re-evaluates on each open
end

return M
