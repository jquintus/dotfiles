-- Chrome profile switching, from the keyboard.
--
-- Chrome has no shortcut for its profile picker, so switching means clicking
-- the avatar and picking from a menu. These bindings jump straight to a
-- profile from anywhere: focus a window that already belongs to it, cycle
-- through that profile's windows on a repeat press, and open a fresh window in
-- the profile if none is on screen. Loaded from init.lua via
-- require("chrome").bind().
--
--   Hyper + P   personal profile
--   Hyper + D   dirtlabs (work) profile
--
-- How a window's profile is identified: with more than one profile signed in,
-- Chrome suffixes every window title with the profile label, e.g.
-- "Inbox - Google Chrome - Josh (dirtlabs.ai)". `label` below is that suffix,
-- matched exactly; `name` is how the profile reads on the Hyper+0 overlay; and
-- `dir` is the directory name under
-- ~/Library/Application Support/Google/Chrome, used only when a new window has
-- to be opened. To re-derive both after renaming or adding a profile:
--
--   hs -c 'require("chrome").labels()'                        -- live labels
--   plutil -extract profile.info_cache raw -o - \
--     ~/Library/Application\ Support/Google/Chrome/Local\ State   -- directories

local M = {}

M.HYPER = { "cmd", "alt", "ctrl", "shift" }

M.PROFILES = {
  { key = "p", label = "Josh",               dir = "Default",   name = "Chrome (personal)" },
  { key = "d", label = "Josh (dirtlabs.ai)", dir = "Profile 1", name = "Chrome (dirtlabs)" },
}

local BUNDLE = "com.google.Chrome"

-- The profile label Chrome appended to a window title, or nil if there is
-- none (single profile signed in, or not a Chrome window). `.*` is greedy, so
-- this anchors on the last " - Google Chrome - " in the title, leaving page
-- titles that happen to contain the same text alone.
local function labelOf(win)
  local title = win and win:title() or ""
  return title:match("^.* %- Google Chrome %- (.+)$")
end

-- Chrome's windows belonging to one profile, front to back.
local function windowsFor(label)
  local matches = {}
  for _, win in ipairs(hs.window.orderedWindows()) do
    local app = win:application()
    if app and app:bundleID() == BUNDLE and labelOf(win) == label then
      matches[#matches + 1] = win
    end
  end
  return matches
end

-- A minimized window of one profile, if there is one.
local function minimizedFor(label)
  local chrome = hs.application.get(BUNDLE)
  for _, win in ipairs(chrome and chrome:allWindows() or {}) do
    if win:isMinimized() and labelOf(win) == label then return win end
  end
end

-- Focus (or open) a profile's window. Exposed on M so it can be driven from a
-- terminal too: `hs -c 'require("chrome").focus("d")'`.
function M.focus(key)
  local profile
  for _, candidate in ipairs(M.PROFILES) do
    if candidate.key == key then profile = candidate end
  end
  if not profile then
    hs.alert.show("No Chrome profile bound to " .. tostring(key))
    return
  end

  local wins = windowsFor(profile.label)

  if #wins == 0 then
    -- Nothing on screen for this profile. A window minimized into the Dock
    -- still counts, since restoring it beats opening a second one.
    local minimized = minimizedFor(profile.label)
    if minimized then
      minimized:unminimize()
      minimized:focus()
      return
    end
    -- Otherwise let Chrome open one. `open -n` does not start a second copy of
    -- Chrome; the running one picks the arguments up and opens a window in the
    -- profile asked for, launching Chrome first if it isn't running at all.
    hs.execute(('open -na "Google Chrome" --args --profile-directory=%q'):format(profile.dir))
    return
  end

  -- Already in this profile: step to the next of its windows, so the same
  -- chord cycles rather than doing nothing.
  local front = hs.window.frontmostWindow()
  local target = wins[1]
  if #wins > 1 and front and labelOf(front) == profile.label then
    target = wins[2]
  end
  target:focus()
end

-- Print the profile label of every open Chrome window, for retuning M.PROFILES
-- after a profile is renamed or added.
function M.labels()
  local seen, out = {}, {}
  for _, win in ipairs(hs.window.orderedWindows()) do
    local app = win:application()
    if app and app:bundleID() == BUNDLE then
      local label = labelOf(win) or "(no profile suffix)"
      if not seen[label] then
        seen[label] = true
        out[#out + 1] = label
      end
    end
  end
  return table.concat(out, "\n")
end

function M.bind(mods)
  M.HYPER = mods or M.HYPER
  local launcher = require("launcher")
  for _, profile in ipairs(M.PROFILES) do
    hs.hotkey.bind(M.HYPER, profile.key, function() M.focus(profile.key) end)
    -- Put these on the Hyper+0 overlay too, so there is one place that answers
    -- "what is bound to what".
    launcher.register(profile.key, profile.name)
  end
end

return M
