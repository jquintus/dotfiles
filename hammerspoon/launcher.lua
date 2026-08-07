-- Hyper-key app launcher.
--
-- One chord jumps straight to an app: launches it if it isn't running, focuses
-- it if it is, and hides it if it's already frontmost (so the same key toggles
-- in and out). This is the thing that makes the Dock unnecessary. Loaded from
-- init.lua via require("launcher").start().
--
-- Two bindings per app, both optional:
--   Hyper + <letter>   mnemonic, e.g. Hyper+C for Chrome
--   Hyper + <number>   positional, mirroring Windows' Win+<n> taskbar jump.
--                      The number is the app's index in M.APPS below (1-9).
--
-- Hyper + 0 shows the cheat sheet, since positional bindings are easy to forget.
-- (0 rather than the more obvious /, because Hyper includes Shift and macOS
-- reserves Cmd+Shift+/ for the Help menu, which swallows the key before
-- Hammerspoon sees it. 0 also sits naturally next to the 1-9 bindings.)
--
-- "Hyper" is Cmd+Alt+Ctrl+Shift, a combination nothing else on macOS claims.
-- It's miserable to press by hand, so it's meant to be driven by a Caps Lock
-- remap (Karabiner-Elements, or a hidutil map). Until that's in place the chord
-- still fires if you genuinely hold all four modifiers.
--
-- To retune, edit M.APPS. `name` is matched by hs.application.find, which
-- accepts an application name or a bundle ID. Prefer the bundle ID when an
-- app's display name differs from its launch name (VS Code launches as
-- "Visual Studio Code" but reports itself as "Code", for instance).

local M = {}

M.HYPER = { "cmd", "alt", "ctrl", "shift" }

-- Ordered: position in this table is the Hyper+<number> binding.
M.APPS = {
  { key = "t", name = "cmux" },
  { key = "c", name = "Google Chrome" },
  { key = "s", name = "Slack" },
  { key = "v", name = "Visual Studio Code", bundle = "com.microsoft.VSCode" },
  { key = "o", name = "Obsidian" },
  { key = "m", name = "MacVim" },
  { key = "g", name = "Google Chat" },
  { key = "p", name = "Spotify" },
  { key = "l", name = "Linear" },
}

-- Launch, focus, or hide, depending on where the app currently stands.
-- Matching by bundle ID when one is given avoids the display-name-vs-launch-name
-- mismatch that would otherwise make the hide-on-repeat branch never fire.
local function jump(app)
  return function()
    local running = hs.application.find(app.bundle or app.name)
    if running and running:isFrontmost() then
      running:hide()
    else
      hs.application.launchOrFocus(app.name)
    end
  end
end

-- Overlay listing every binding, for when the positional ones fall out of head.
-- Exposed on M so it can be invoked directly (`hs -c 'require("launcher").cheatSheet()'`)
-- without having to synthesize a Hyper keystroke, which is unreliable to fake.
function M.cheatSheet()
  local lines = {}
  for i, app in ipairs(M.APPS) do
    local keys = (i <= 9) and ("  " .. i) or "   "
    if app.key then keys = keys .. "  " .. app.key:upper() else keys = keys .. "   " end
    lines[#lines + 1] = keys .. "   " .. app.name
  end
  hs.alert.closeAll()
  hs.alert.show("HYPER +\n\n" .. table.concat(lines, "\n"), 3)
end

-- Bind everything. `mods` overrides the Hyper definition if you'd rather drive
-- this from a different modifier set.
function M.start(mods)
  M.HYPER = mods or M.HYPER

  for i, app in ipairs(M.APPS) do
    if i <= 9 then
      hs.hotkey.bind(M.HYPER, tostring(i), jump(app))
    end
    if app.key then
      hs.hotkey.bind(M.HYPER, app.key, jump(app))
    end
  end

  hs.hotkey.bind(M.HYPER, "0", M.cheatSheet) -- Show these bindings
end

return M
