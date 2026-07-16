-- Join your next Google Meet from the calendar (via gcalcli).
--
-- Binds Option+Ctrl+Shift+F7 to find the next calendar event with a Meet link
-- (from 5 minutes ago through the next 12 hours, so an in-progress or imminent
-- meeting counts) and open it in Chrome. Loaded from init.lua via
-- require("meeting").bind().
--
-- Requires gcalcli to be authenticated on this machine (see README / dotfiles
-- notes). Until then F7 just reports that no meeting was found.

local M = {}

-- The next Meet link in the window, or nil. gcalcli agenda is chronological, so
-- the first meet.google.com URL is the soonest meeting. --details all ensures
-- the link is present whether Google exposes it as conference data, in the
-- description, or the location.
local function nextMeetLink()
  local cmd = [[gcalcli --nocolor agenda "$(date -v-5M '+%Y-%m-%dT%H:%M')" "$(date -v+12H '+%Y-%m-%dT%H:%M')" --details all 2>/dev/null | grep -oiE 'https://meet\.google\.com/[a-z-]+' | head -1]]
  local out = hs.execute(cmd, true) or "" -- true: load login shell so gcalcli is on PATH
  out = out:gsub("%s+", "")
  if out == "" then return nil end
  return out
end

function M.joinNext()
  local link = nextMeetLink()
  if not link then
    hs.alert.show("No upcoming Meet found")
    return
  end
  hs.execute("open -a 'Google Chrome' '" .. link .. "'", true)
  hs.alert.show("📅 Joining next meeting")
end

function M.bind(mods)
  mods = mods or { "alt", "ctrl", "shift" }
  hs.hotkey.bind(mods, "f7", M.joinNext) -- Join next meeting (M-C-S-F7)
end

return M
