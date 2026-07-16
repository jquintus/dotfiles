-- Desktop layout chord.
--
-- One chord (default Option+Ctrl+Shift+F2) arranges your windows into the
-- layout that matches however many external monitors are currently connected
-- (0 / 1 / 2+). Also re-applies automatically when you plug or unplug a
-- display. Loaded from init.lua via require("layout").start().
--
-- To retune, edit the three tables in M.apply() below. Positions are fractional
-- unit rects on the target screen, so they are resolution-independent:
--   FULL = whole screen, LEFT = left half, RIGHT = right half.

local M = {}

local FULL  = hs.geometry.rect(0, 0, 1, 1)
local LEFT  = hs.geometry.rect(0, 0, 0.5, 1)
local RIGHT = hs.geometry.rect(0.5, 0, 0.5, 1)

-- The built-in laptop display (falls back to the primary screen if the name
-- match fails on some future macOS).
local function builtinScreen()
  for _, s in ipairs(hs.screen.allScreens()) do
    if s:name():lower():find("built") then return s end
  end
  return hs.screen.primaryScreen()
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

-- Keep only rows whose app is actually running, so hs.layout.apply never trips
-- over a missing app.
local function present(rows)
  local out = {}
  for _, row in ipairs(rows) do
    if hs.application.find(row[1]) then out[#out + 1] = row end
  end
  return out
end

function M.apply()
  local builtin = builtinScreen()
  local ext = externalScreens(builtin)
  local n = #ext
  local rows

  if n == 0 then
    -- Laptop only: work apps split the screen, Slack maximized behind them.
    rows = {
      { "cmux",          nil, builtin, LEFT,  nil, nil },
      { "Google Chrome", nil, builtin, RIGHT, nil, nil },
      { "Slack",         nil, builtin, FULL,  nil, nil },
    }
  elseif n == 1 then
    -- One external: work apps share the big screen, Slack on the laptop.
    rows = {
      { "cmux",          nil, ext[1],  LEFT,  nil, nil },
      { "Google Chrome", nil, ext[1],  RIGHT, nil, nil },
      { "Slack",         nil, builtin, FULL,  nil, nil },
    }
  else
    -- Two (or more) externals: one work app per external, Slack on the laptop.
    rows = {
      { "cmux",          nil, ext[1],  FULL, nil, nil },
      { "Google Chrome", nil, ext[2],  FULL, nil, nil },
      { "Slack",         nil, builtin, FULL, nil, nil },
    }
  end

  hs.layout.apply(present(rows))
  hs.alert.show("🪟 Layout: " .. (n == 0 and "laptop only" or (n .. " external")))
end

-- Bind the chord and (optionally) watch for display changes.
-- mods defaults to Option+Ctrl+Shift (vim M-C-S; on macOS vim "M"/Meta = Option).
function M.start(mods)
  mods = mods or { "alt", "ctrl", "shift" }
  hs.hotkey.bind(mods, "f2", M.apply) -- Arrange desktop (M-C-S-F2)

  -- Re-apply after displays settle when a monitor is connected/disconnected.
  M.watcher = hs.screen.watcher.new(function()
    hs.timer.doAfter(1.5, M.apply)
  end)
  M.watcher:start()
end

return M
