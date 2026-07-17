-- Desktop layout chord.
--
-- One chord (default Option+Ctrl+Shift+F2) arranges your windows into the
-- layout that matches however many external monitors are currently connected
-- (0 / 1 / 2+). Also re-applies automatically when you plug or unplug a
-- display. Loaded from init.lua via require("layout").start().
--
-- With 0 externals (laptop only) cmux, Chrome, and Spotify go into native
-- macOS full screen (as if you clicked the green traffic-light button, each in
-- its own Space); Slack is maximized behind them. With 1+ externals those apps
-- are pulled back out of full screen and tiled, so nothing stays green-dotted.
--
-- To retune, edit the tables in M.apply() below. Positions are fractional unit
-- rects on the target screen, so they are resolution-independent:
--   FULL = whole screen, LEFT = left half, RIGHT = right half.

local M = {}

local FULL    = hs.geometry.rect(0, 0, 1, 1)
local LEFT    = hs.geometry.rect(0, 0, 0.5, 1)
local RIGHT   = hs.geometry.rect(0.5, 0, 0.5, 1)
local LEFT23  = hs.geometry.rect(0, 0, 2 / 3, 1)     -- left two-thirds
local RIGHT23 = hs.geometry.rect(1 / 3, 0, 2 / 3, 1) -- right two-thirds

-- The built-in laptop display, or nil if it isn't currently attached (e.g. the
-- lid is closed in clamshell mode, so macOS reports only the external).
local function findBuiltin()
  for _, s in ipairs(hs.screen.allScreens()) do
    if s:name():lower():find("built") then return s end
  end
  return nil
end

-- Same, but falls back to the primary screen if the name match fails on some
-- future macOS, so M.apply() always has a screen to target.
local function builtinScreen()
  return findBuiltin() or hs.screen.primaryScreen()
end

-- External displays, ordered left-to-right by physical position.
local function externalScreens(builtin)
  local ext = {}
  for _, s in ipairs(hs.screen.allScreens()) do
    if s ~= builtin then ext[#ext + 1] = s end
  end
  table.sort(ext, function(a, b) return a:frame().x < b:frame().x end)
  return ext
end

-- Apps that go native full screen (green traffic-light button) when the laptop
-- is running standalone, and get pulled back out otherwise.
local FULLSCREEN_APPS = { "cmux", "Google Chrome", "Spotify" }

-- Keep only rows whose app is actually running, so hs.layout.apply never trips
-- over a missing app.
local function present(rows)
  local out = {}
  for _, row in ipairs(rows) do
    if hs.application.find(row[1]) then out[#out + 1] = row end
  end
  return out
end

-- Put each named app's main window into native full screen (its own Space).
local function enterFullScreen(names)
  for _, name in ipairs(names) do
    local app = hs.application.find(name)
    local win = app and app:mainWindow()
    if win and not win:isFullScreen() then win:setFullScreen(true) end
  end
end

-- Pull each named app's main window out of native full screen. Returns true if
-- any window was actually toggled (the exit animation takes ~1s, so callers
-- that want to tile afterwards should wait for it to settle first).
local function exitFullScreen(names)
  local changed = false
  for _, name in ipairs(names) do
    local app = hs.application.find(name)
    local win = app and app:mainWindow()
    if win and win:isFullScreen() then
      win:setFullScreen(false)
      changed = true
    end
  end
  return changed
end

function M.apply()
  local builtin = builtinScreen()
  local ext = externalScreens(builtin)
  local n = #ext

  if n == 0 then
    -- Laptop only: cmux, Chrome, Spotify go native full screen (green button),
    -- Slack maximized behind them.
    enterFullScreen(FULLSCREEN_APPS)
    hs.layout.apply(present({
      { "Slack", nil, builtin, FULL, nil, nil },
    }))
  else
    local rows
    if n == 1 then
      -- One external: work apps share the big screen, Slack on the laptop.
      rows = {
        { "cmux",          nil, ext[1],  RIGHT, nil, nil },
        { "Google Chrome", nil, ext[1],  LEFT,  nil, nil },
        { "Slack",         nil, builtin, FULL,  nil, nil },
      }
    else
      -- Two (or more) externals: cmux + Chrome overlap on the first external
      -- (right 2/3 and left 2/3), Slack on the left 2/3 of the second external.
      rows = {
        { "cmux",          nil, ext[1], RIGHT23, nil, nil },
        { "Google Chrome", nil, ext[1], LEFT23,  nil, nil },
        { "Slack",         nil, ext[2], LEFT23,  nil, nil },
      }
    end

    -- Nothing stays green-dotted with externals attached. If we had to exit
    -- full screen, wait for the animation to settle before tiling.
    local changed = exitFullScreen(FULLSCREEN_APPS)
    local tile = function() hs.layout.apply(present(rows)) end
    if changed then hs.timer.doAfter(1.0, tile) else tile() end
  end

  hs.alert.show("🪟 Layout: " .. (n == 0 and "laptop only" or (n .. " external")))
end

-- Bind the chord and (optionally) watch for display changes.
-- mods defaults to Option+Ctrl+Shift (vim M-C-S; on macOS vim "M"/Meta = Option).
function M.start(mods)
  mods = mods or { "alt", "ctrl", "shift" }
  hs.hotkey.bind(mods, "f2", M.apply) -- Arrange desktop (M-C-S-F2)

  -- Track whether we've ever actually seen the built-in display, so a future
  -- macOS that stops matching the "built" name doesn't make us skip forever.
  M.sawBuiltin = findBuiltin() ~= nil

  -- Re-apply after displays settle when a monitor is connected/disconnected,
  -- EXCEPT when the built-in display vanishes while an external stays attached.
  -- That's closing the laptop lid in clamshell mode: "I'm done for the day",
  -- not "rearrange". Leave the windows where they are. (The M-C-S-F2 chord
  -- still re-tiles on demand if you ever want a clamshell layout.)
  M.watcher = hs.screen.watcher.new(function()
    hs.timer.doAfter(1.5, function()
      if findBuiltin() then
        M.sawBuiltin = true
      elseif M.sawBuiltin and #hs.screen.allScreens() > 0 then
        return -- lid closed with a monitor still connected: don't touch windows
      end
      M.apply()
    end)
  end)
  M.watcher:start()
end

return M
